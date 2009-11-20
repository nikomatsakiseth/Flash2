//
//  Model.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "LanguageVersion.h"
#import "History.h"
#import "GrammarRuleHistory.h"
#import "PropertyHistory.h"
#import "Property.h"

#define E_LANGUAGE_VERSION @"LanguageVersion"
#define E_GRAMMAR_RULE_HISTORY @"GrammarRuleHistory"
#define E_CARD @"Card"
#define E_PROPERTY @"Property"

@class Language;

// Try to keep complicated queries in here so as to make it easier to find
// all strings containing key names.  Using the constants above is
// acceptable, though.
@interface NSManagedObjectContext (CardSetQueries) 

#pragma mark Queries

- (LanguageVersion*) languageVersionForLanguage:(Language*)language;

#pragma mark New Objects

@end

@interface Card (Additions)

- (BOOL)hasRelatedText:(NSString*)aRelationName;
- (NSString*)relatedText:(NSString*)aRelationName;
- (NSArray*)relatedTexts:(NSString*)aRelationName;
- (NSString*)relatedText:(NSString*)aRelationName ifNone:(NSString*)dflt;
- (NSArray*)relatedProperties:(NSString*)aRelationName;

@end
