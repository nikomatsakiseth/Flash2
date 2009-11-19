//
//  AddCardController.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AddCardController.h"
#import "OxKeyValue.h"
#import "Card.h"
#import "OxNSSet.h"
#import "OxObservableArray.h"
#import "OxNSString.h"
#import "OxNSArray.h"
#import "Queries.h"
#import "Ox.h"
#import "CardUIBuilder.h"
#import "OxNSTextField.h"

@implementation AddCardController

@synthesize language = a_language;

- (void) observeValueForKeyPath:(NSString*)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary*)change 
                        context:(void*)context
{
    invokeObservationSelector(self, keyPath, object, change, context);
}

- (void) awakeFromNib {
    m_mctx = [m_cardSet managedObjectContext];
	m_relations = [NSArrayController new];
	[m_relations bind:@"contentArray" toObject:self withKeyPath:@"language.relations" options:nil];	
    [self addObserver:self forKeyPath:@"language" options:0 context:nil];
	self.language = [[m_cardSet languages] _0]; // indirectly causes a [self reset:self]!
}

#pragma mark -
#pragma mark New Cards

@synthesize fromString = a_fromString;
@synthesize newCards = a_newCards;

- (IBAction) addRow:(id)sender
{  
    if (self.language == nil)
        return;
	
	id relation = [[self.language relations] _0];
    id newCard = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				  @"" FOR @"toString", 
				  relation FOR @"relation", 
				  nil];
	
	self.newCards = [self.newCards arrayByAddingObject:newCard];
	
	// Reshape the GUI:
	CardUIBuilder *builder = [[CardUIBuilder alloc] initWithWindow:m_window delegate:self];
	[builder resizeBox:m_box toCards:[self.newCards count] relationClass:[NSPopUpButton class]];
}

// invoked by CardUIBuilder for each row:
- (void) configureRow:(int)row views:(NSArray*)views
{
	NSDictionary *opts = OxDict(OxInt(1) FOR NSContinuouslyUpdatesValueBindingOption,
								OxInt(0) FOR NSConditionallySetsEditableBindingOption);
	NSDictionary *card = [self.newCards objectAtIndex:row];
	
	// bind from and to string:
	[[views _0] bind:@"value" toObject:self withKeyPath:@"fromString" options:opts];
	[[views _2] bind:@"value" toObject:card withKeyPath:@"toString" options:opts];		
	if (row != 0) {
		[[views _0] configureIntoLabel]; // except for 1st, make read-only
		[[views _0] setEditable:NO];
	}
	
	// bind language details:
	[[views _0] bind:@"keyboardIdentifier" toObject:self withKeyPath:@"language.keyboardIdentifier" options:nil];
	[[views _2] bind:@"keyboardIdentifier" toObject:card withKeyPath:@"relation.toStringKeyboardIdentifier" options:nil]; // wrong
	
	// bind pop-up:
	[[views _1] bind:@"content" toObject:m_relations withKeyPath:@"arrangedObjects" options:opts];
	[[views _1] bind:@"contentValues" toObject:m_relations withKeyPath:@"arrangedObjects.name" options:opts];
	[[views _1] bind:@"selectedObject" toObject:card withKeyPath:@"relation" options:opts];
}

- (void) observeValueForLanguageOfObject:(id)object 
                                  change:(NSDictionary*)change 
                                 context:(void*)context
{
    // when language changes, reset the relations and all
    NSAssert(object == self, @"Observation for an object besides self");
    [self reset:self];
}

#pragma mark -
#pragma mark Existing Cards

+ (NSSet*) keyPathsForValuesAffectingExistingCardsPredicate {
    return [NSSet setWithObjects:
			@"fromString", 
			@"newCards.toString", 
			@"language",
			nil];
}

- (NSPredicate*) existingCardsPredicate
{
	if (self.language == nil)
		return nil; // happens during init sometimes
	
	NSMutableDictionary *vars = [NSMutableDictionary dictionary];	
	NSMutableString *predicateString = [NSMutableString stringWithString:@"languageVersion.identifier == $lv"];
	[vars setObject:[self.language identifier] forKey:@"lv"]; // avoid creating a LanguageVersion if not needed
	
	NSArray *fromStrings = OxArr(self.fromString);
	NSArray *toStrings = [self.newCards valueForKeyPath:@"toString"];
	NSMutableSet *allStrings = [NSMutableSet setWithUnionOfArrays:fromStrings, toStrings, nil];
	[allStrings removeObject:@""];
	
	if (![allStrings isEmpty]) {
		NSMutableArray *clauses = [NSMutableArray array];
		int counter = 0;
		for (NSString *string in allStrings) {
			NSString *varName = [NSString stringWithFormat:@"str%d", counter++];
			[vars setValue:string forKey:varName];
			[clauses addObject:[NSString stringWithFormat:@"fromString contains[cd] $%@", varName]];
			[clauses addObject:[NSString stringWithFormat:@"toString contains[cd] $%@", varName]];
		}	
		NSString *clausesString = [clauses componentsJoinedByString:@" OR "];
		[predicateString appendFormat:@" AND (%@)", clausesString];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	return [predicate predicateWithSubstitutionVariables:vars];
}

#pragma mark -
#pragma mark Actions

- (IBAction) addAll:(id)sender {
	NSString *fromString = self.fromString;
    for (NSDictionary *dict in self.newCards) {
        NSString *relationName = [[dict valueForKey:@"relation"] name];
        NSString *toString = [dict valueForKey:@"toString"];
        
        [dict setValue:@"" forKey:@"fromString"];
        [dict setValue:@"" forKey:@"toString"];
        
        if (!fromString || [fromString isEqual:@""] || 
			[relationName isEqual:@""] || 
			!toString || [toString isEqual:@""]) 
            continue;
        
		[m_mctx createNewCardFromString:fromString 
						   relationName:relationName 
							   toString:toString 
							   language:self.language];
    }
}

- (IBAction) reset:(id)sender {
    self.newCards = [OxObservableArray array];
    [self addRow:nil];
}

@end
