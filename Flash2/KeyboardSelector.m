//
//  KeyboardSelector.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeyboardSelector.h"
#import "Ox.h"
#import "Language.h"
#import "Carbon/Carbon.h"
#import "OxNSArray.h"
#import "Language.h"
#import "Config.h"
#import "OxNSString.h"

@implementation KeyboardSelector

- init
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(test:) name:NSControlTextDidBeginEditingNotification object:nil];
	[center addObserver:self selector:@selector(test:) name:NSControlTextDidEndEditingNotification object:nil];
	return self;
}

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	[super dealloc];
}

- (void) test:(NSNotification*)not
{
	NSLog(@"notification: %@", not);
}

- (void) setCardSet:(CardSet*)cardSet
{
	m_cardSet = cardSet;
}

void logBindings(NSString *name, id object) {
	NSLog(@"%@ -----------------------------------------", name);
	for (id binding in [object exposedBindings]) {//[NSArray arrayWithObjects:@"value", @"content", @"selectedObject", nil]) {
		NSLog(@"attempting binding %@ of %@", binding, object);
		NSDictionary *bindingInfo = [object infoForBinding:binding];
		if (bindingInfo != nil) {
			for (id key in [bindingInfo allKeys])
				NSLog(@"  Key=%@ Value=%@", key, [bindingInfo objectForKey:key]);
		} else {
			NSLog(@"  not bound");
		}
	}
}

id boundObject(id object, id binding) {
	NSDictionary *bindingInfo = [object infoForBinding:binding];
	if (bindingInfo != nil) {
		id object = [bindingInfo valueForKey:NSObservedObjectKey];
		id keyPath = [bindingInfo valueForKey:NSObservedKeyPathKey];
		return [object valueForKeyPath:keyPath];
	}
	return nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	// Find the card at this column.
	NSTableColumn *relColumn = [aTableView tableColumnWithIdentifier:@"relation"];
	NSDictionary *bindingInfo = [relColumn infoForBinding:@"selectedValue"];
	id controller = [bindingInfo valueForKey:NSObservedObjectKey];
	NSString *relNameKeyPath = [bindingInfo valueForKey:NSObservedKeyPathKey];
	NSArray *relNames = [controller valueForKeyPath:relNameKeyPath];
	NSString *cardsKeyPath = [relNameKeyPath sliceTo:-[@".relationName" length]];
	NSArray *cards = [controller valueForKeyPath:cardsKeyPath];
	Card *card = [cards objectAtIndex:rowIndex];
	Language *language = [m_cardSet languageForCard:card];
	if (language == nil)
		return NO; // this shouldn't happen
	
	// find the relation
	NSString *relName = [relNames objectAtIndex:rowIndex];
	Relation *relation = [language relationNamed:relName];
	if (relation == nil)
		return NO; // this shouldn't happen
		
	// Determine the keyboard for this language.
	TISInputSourceRef languageKb = NULL;
	if (language) { // program defensively here... shouldn't be nil though
		NSString *languageKbId = [language keyboardIdentifier];
		NSArray *languageKbs = (NSArray*)TISCreateInputSourceList(CfDict(languageKbId FOR kTISPropertyInputSourceID), true);
		languageKb = (TISInputSourceRef)[languageKbs anyObject];
	}
	
	// If the word being entered is in 'language', then use 'languageKb'.
	// Otherwise, use the default keyboard.
	if ([[aTableColumn identifier] isEqual:@"fromString"]) {
		if (languageKb != NULL) // who knows, maybe user doesn't have this keyboard or something
			TISSelectInputSource(languageKb);
	} else if ([[aTableColumn identifier] isEqual:@"toString"]) {
		if ([relation crossLanguage])
			selectDefaultKeyboard();
		else if (languageKb != NULL)
			TISSelectInputSource(languageKb);
	}
	
	return YES;
}

- (id)windowWillReturnFieldEditor:(NSWindow *)window 
						 toObject:(id)anObject 
{
	if ([anObject isKindOfClass:[NSTableView class]])
		return nil; // weird stuff happens
	
	//NSLog(@"windowWillReturnFieldEditorToObject: %@ (tag = %d)", anObject, [anObject tag]);
	if (m_textView == nil) {
		m_textView = [[FlashTextView alloc] initWithFrame:[anObject frame]];
		[m_textView setFieldEditor:YES];
	}
	
	// Is this object configured to switch into the language's keyboard?
	NSString *keyboardIdentifier;
	if ([anObject respondsToSelector:@selector(keyboardIdentifier)])
		keyboardIdentifier = [anObject keyboardIdentifier];
	else
		keyboardIdentifier = nil;
	[m_textView setKeyboardIdentifierToUseWhenActive:keyboardIdentifier];
	
	return m_textView;
}

@end
