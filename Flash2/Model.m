//
//  Model.m
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Model.h"
#import "Language.h"
#import "Ox.h"
#import "OxCoreData.h"
#import "OxDebug.h"
#import "OxNSArray.h"

@implementation NSManagedObjectContext (CardSetQueries)

- (LanguageVersion*) languageVersionForLanguage:(id<Language>)language
{
	LanguageVersion *lv = [self objectOfEntityType:E_LANGUAGE_VERSION
						   matchingPredicateFormat:@"identifier = %@", [language identifier]];
	if (lv == nil) {
		OxLog(@"Creating new language version for %p %@ %@", language, [language name], [language identifier]);
		lv = [NSEntityDescription insertNewObjectForEntityForName:E_LANGUAGE_VERSION
										   inManagedObjectContext:self];
		lv.identifier = [language identifier];
		lv.version = OxInt([language languageVersion]);
	}
	
	// These should be updated when the file is loaded:
	NSAssert([lv.version intValue] == [language languageVersion], @"Language Version is out of date");	
	
	return lv;
}

- (Card*)newCardWithText:(NSString*)aText 
					kind:(NSString*)aKind
				language:(id<Language>)aLanguage
{
	LanguageVersion *lv = [self languageVersionForLanguage:aLanguage];
	Card *card = [NSEntityDescription insertNewObjectForEntityForName:E_CARD
											   inManagedObjectContext:self];
	card.text = aText;
	card.cardKind = aKind;
	card.languageVersion = lv;
	return card;
}

- (UserProperty*)newUserPropertyForCard:(Card*)aCard text:(NSString*)aText relationName:(NSString*)aRelationName
{
	UserProperty *userProperty = [NSEntityDescription insertNewObjectForEntityForName:E_USER_PROPERTY
															   inManagedObjectContext:self];
	userProperty.card = aCard;
	userProperty.text = aText;
	userProperty.relationName = aRelationName;
	return userProperty;
}

- (History*)newHistoryWithQuizzable:(Quizzable*)quizzable 
							inverse:(BOOL)inverse
						   duration:(double)duration
							correct:(double)correct
{
	History *history = [NSEntityDescription insertNewObjectForEntityForName:E_HISTORY
													 inManagedObjectContext:self];
	history.quizzable = quizzable;
	history.duration = OxDouble(duration);
	history.inverse = inverse;
	history.correct = OxDouble(correct);
	history.total = OxDouble(1.0);
	return history;
}

@end

@implementation Card (Additions)

//void userSetString(id self, SEL getSel, SEL setSel, NSString *string) {
//	NSString *oldString = [self performSelector:getSel];
//	if ([oldString isEqual:string])
//		return; // no change required
//	
//	[self performSelector:setSel withObject:string];
//	
//	UpdateCardController *ucc = [[UpdateCardController alloc] initWithOldSpelling:oldString 
//																	  newSpelling:string 
//															 managedObjectContext:[self managedObjectContext]];
//	[ucc execute];
//}

- (NSString*) description 
{
	return OxFmt(@"<Card %@>", self.text);
}

- (NSArray*)relatedUserProperties:(NSString*)aRelationName
{
	return [[self.properties filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL(id object, NSDictionary *bindings) {
		return [[object relationName] isEqualToString:aRelationName] && ![object isDeleted];
	}]] allObjects];
}

- (BOOL)hasRelatedText:(NSString*)aRelationName
{
	return ![[self relatedUserProperties:aRelationName] isEmpty];
}

- (NSArray*)relatedTexts:(NSString*)aRelationName
{
	return [[self relatedUserProperties:aRelationName] valueForKey:@"text"];
}

- (NSString*)relatedText:(NSString*)aRelationName
{
	NSArray *texts = [self relatedTexts:aRelationName];
	if([texts isEmpty])
		return nil;
	return [texts _0];
}

- (NSString*)relatedText:(NSString*)aRelationName ifNone:(NSString*)dflt
{
	NSString *relatedText = [self relatedText:aRelationName];
	if(relatedText == nil)
		return dflt;
	return relatedText;	   
}

@end

@implementation History (Additions)

+ (NSSet *) keyPathsForValuesAffectingInverse
{
	return OxSet(@"inverseObject");
}

- (BOOL) inverse
{
	return [self.inverseObject boolValue];
}

- (void) setInverse:(BOOL)val
{
	self.inverseObject = [NSNumber numberWithBool:val];
}

@end