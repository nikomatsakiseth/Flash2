//
//  BaseLanguage.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Card.h"
#import "Language.h"

@class QuizCard;

// Most languages generally provide some kind of Equivalent relation.
#define REL_EQUIVALENT @"Equivalent"

@interface WordCategory : NSObject {
	Card *m_word;
	id m_lang;
} 

- initWithCard:(Card*)word language:(id)lang;

@end

@interface BaseLanguage : Language {
}

// Abstract method: Attempts to conjugate Word into the given person/plural
// combination.  Returns nil if it cannnot be done (perhaps the word is not
// a recognized kind of verb, for example).
- (NSArray*) conjugate:(Card*)card person:(int)person plural:(BOOL)plural;

// Array of all verb tenses supported by this language.
- (NSArray*) tenseNames;

// Returns a list of relation names that describe how to 
// conjugate a verb into the given combination of tense/person/plural.
// Some languages, such as Greek, only have one relation per tense,
// but others, like French, may have separate relations for each person/plural,
// or even multiple relations for a single tense (passe composee has a helper
// verb and a past participle, for example).
- (NSArray*) relationNamesForTense:(int)tense person:(int)person plural:(int)plural;

@end

#if 0
@interface EquivalentQuizQuestionFactory : QuizQuestionFactory {
}
- (QuizQuestion*) makeQuestionForWord:(Card*)word deck:(Deck*)deck promptingLeft:(BOOL)promptingLeft;
@end

// Base code for a QQF that attempts to conjugate verbs.
@interface BaseConjugationQuizQuestionFactory : QuizQuestionFactory {
	id m_language;
}

- initWithLanguage:(id)language;

// *Abstract:* Returns a tuple (tense, person, plural) that we should
// prompt the user with (i.e., show both sides), or nil.
- (NSArray*) promptTense;

// *Abstract:* Returns a list of (tense, person, plural) tuples that
// we should quiz the user on.  `promptTense` is the
// value returned by a previous send of `promptTense`.
- (NSArray*) tensesToTest:(NSArray*)promptTense;

// *Optional:* Returns the text to prompt the user with when asking
// for the given tense tuple.  Default is the name of the tense.
- (NSString*) promptRelationNameForTense:(NSArray*)tense;

// *Optional:* Returns the subtitle to display, if any.  Default is "".
- (NSString*) subtitle:(NSArray*)promptTense;

// By default, just returns nil: subclasses should override to determine
// if 'deck' represents a kind of verb, find an appropriate instance, and
// invoke makeQuestionForRelationNamed:ofWord:deck:
- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck;

// If relation is one of the tenses to test (see constructor), then
// generates a quiz question requesting the conjugations in each tense
// that we test.  Assumes that the language supports conjugate:person:plural:
- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Card*)word deck:(Deck*)deck;

@end
#endif