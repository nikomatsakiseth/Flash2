//
//  Queries.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Queries.h"
#import "OxCoreData.h"
#import "Ox.h"
#import "OxDebug.h"
#import "Card.h"

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

- (NSArray*) mostRecentHistoriesExpiringBefore:(NSDate*)date language:(Language*)language
{
	LanguageVersion *lv = [self languageVersionForLanguage:language];
	NSArray *grammarRuleHistories = [self objectsOfEntityType:E_GRAMMAR_RULE_HISTORY
									  matchingPredicateFormat:@"expirationDate <= %@ AND mostRecent = YES AND languageVersion = %@", 
									 date, lv];
	NSArray *cardHistories = [self objectsOfEntityType:E_CARD_HISTORY
							   matchingPredicateFormat:@"expirationDate <= %@ AND mostRecent = YES AND card.languageVersion = %@",
							  date, lv];
	return [grammarRuleHistories arrayByAddingObjectsFromArray:cardHistories];
}

- (CardHistory*) mostRecentHistoryForCard:(Card*)card
{
	return [self objectOfEntityType:E_CARD_HISTORY
			matchingPredicateFormat:@"card = %@ AND mostRecent = YES", card];
}

- (GrammarRuleHistory*) mostRecentHistoryForGrammarRuleNamed:(NSString*)name language:(Language*)language
{
	LanguageVersion *lv = [self languageVersionForLanguage:language];
	return [self objectOfEntityType:E_GRAMMAR_RULE_HISTORY
			matchingPredicateFormat:@"grammarRuleName = %@ AND languageVersion = %@ AND mostRecent = YES", name, lv];
}

- (NSArray*) cardsWithNoHistoryInLanguage:(Language*)language
{
	LanguageVersion *lv = [self languageVersionForLanguage:language];
	return [self objectsOfEntityType:E_CARD
			 matchingPredicateFormat:@"histories[SIZE] = 0 AND languageVersion = %@", lv];
}

- (NSArray*) cardsWithFromString:(NSString*)fromText languageVersion:(LanguageVersion*)lv
{
	return [self objectsOfEntityType:E_CARD
			 matchingPredicateFormat:@"fromStringCommit = %@ AND languageVersion = %@", fromText, lv];
}

- (NSArray*) cardsWithFromString:(NSString*)fromText 
					relationName:(NSString*)relationName 
						language:(Language*)language
{
	LanguageVersion *lv = [self languageVersionForLanguage:language];
	//NSArray *result = [self objectsOfEntityType:E_CARD
	//					matchingPredicateFormat:@"fromStringCommit = %@ AND relationName = %@",
	//				   fromText, relationName];
	NSArray *result = [self objectsOfEntityType:E_CARD
			 matchingPredicateFormat:@"fromStringCommit = %@ AND relationName = %@ AND languageVersion = %@", 
			fromText, relationName, lv];
	OxLog(@"cards matching %@ -%@-> with lv %p (%@) = %@", fromText, relationName, lv, [language name], result);
	
	return result;
}

- (Card*) createNewCardFromString:(NSString*)fromString
					 relationName:(NSString*)relationName
						 toString:(NSString*)toString
						 language:(Language*)language
{
	LanguageVersion *lv = [self languageVersionForLanguage:language];
	Card *card = [NSEntityDescription insertNewObjectForEntityForName:E_CARD
											   inManagedObjectContext:self];
	card.fromStringCommit = fromString;
	card.relationName = relationName;
	card.toStringCommit = toString;
	card.languageVersion = lv;
	return card;
}

@end
