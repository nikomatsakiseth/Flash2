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

- (LanguageVersion*) languageVersionForLanguage:(Language*)language
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

- (Card*)newCardWithText:(NSString*)text language:(Language*)language
{
	LanguageVersion *lv = [self languageVersionForLanguage:language];
	Card *card = [NSEntityDescription insertNewObjectForEntityForName:E_CARD
											   inManagedObjectContext:self];
	card.text = text;
	card.languageVersion = lv;
	return card;
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

- (NSArray*)relatedProperties:(NSString*)aRelationName
{
	return [[self managedObjectContext] objectsOfEntityType:E_PROPERTY matchingPredicateFormat:@"relationName == %@", aRelationName];
}

- (BOOL)hasRelatedText:(NSString*)aRelationName
{
	return ![[self relatedProperties:aRelationName] isEmpty];
}

- (NSArray*)relatedTexts:(NSString*)aRelationName
{
	return [[self relatedProperties:aRelationName] valueForKey:@"text"];
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
