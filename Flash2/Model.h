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
#import "UserProperty.h"
#import "Quizzable.h"

#define E_LANGUAGE_VERSION @"LanguageVersion"
#define E_HISTORY @"History"
#define E_CARD @"Card"
#define E_USER_PROPERTY @"UserProperty"

@protocol Language;

// Try to keep complicated queries in here so as to make it easier to find
// all strings containing key names.  Using the constants above is
// acceptable, though.
@interface NSManagedObjectContext (CardSetQueries) 

#pragma mark Queries

- (LanguageVersion*)languageVersionForLanguage:(id<Language>)language;

#pragma mark New Objects

- (Card*)newCardWithText:(NSString*)text kind:(NSString*)aKind language:(id<Language>)language;
- (UserProperty*)newUserPropertyForCard:(Card*)aCard text:(NSString*)aText relationName:(NSString*)aRelationName;
- (History*)newHistoryWithQuizzable:(Quizzable*)quizzable
							inverse:(BOOL)inverse
						   duration:(double)duration
							correct:(double)correct;

@end

@interface Card (Additions)

- (BOOL)hasRelatedText:(NSString*)aRelationName;
- (NSString*)relatedText:(NSString*)aRelationName;
- (NSArray*)relatedTexts:(NSString*)aRelationName;
- (NSString*)relatedText:(NSString*)aRelationName ifNone:(NSString*)dflt;
- (NSArray*)relatedUserProperties:(NSString*)aRelationName;

@end

@interface History (Additions)

@property(assign) BOOL inverse;

@end