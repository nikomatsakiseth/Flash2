//
//  Queries.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LanguageVersion.h"
#import "Language.h"
#import "CardHistory.h"
#import "GrammarRuleHistory.h"

#define E_LANGUAGE_VERSION @"LanguageVersion"
#define E_GRAMMAR_RULE_HISTORY @"GrammarRuleHistory"
#define E_CARD @"Card"
#define E_CARD_HISTORY @"CardHistory"

#define K_GRAMMAR_RULE_NAME @"grammarRuleName" // E_GRAMMAR_RULE_HISTORY
#define K_TO_STRING @"toString" // E_CARD

// Try to keep complicated queries in here so as to make it easier to find
// all strings containing key names.  Using the constants above is
// acceptable, though.
@interface NSManagedObjectContext (CardSetQueries) 

#pragma mark Queries

- (LanguageVersion*) languageVersionForLanguage:(Language*)language;
- (NSArray*) mostRecentHistoriesExpiringBefore:(NSDate*)date language:(Language*)language;
- (CardHistory*) mostRecentHistoryForCard:(Card*)card;
- (GrammarRuleHistory*) mostRecentHistoryForGrammarRuleNamed:(NSString*)name language:(Language*)language;
- (NSArray*) cardsWithNoHistoryInLanguage:(Language*)language;
- (NSArray*) cardsWithFromString:(NSString*)fromText languageVersion:(LanguageVersion*)lv;
- (NSArray*) cardsWithFromString:(NSString*)fromText 
					relationName:(NSString*)relationName 
						language:(Language*)language;

#pragma mark New Objects

- (Card*) createNewCardFromString:(NSString*)fromString
					 relationName:(NSString*)relationName
						 toString:(NSString*)toString
						 language:(Language*)language;

@end
