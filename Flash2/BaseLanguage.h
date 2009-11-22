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

@interface Relation : NSObject {
    NSString *name;
    BOOL crossLanguage;
	NSString *cardKind;
}

// Not part of the required interface.
- initWithName:(NSString*)aName 
 crossLanguage:(BOOL)aCrossLanguage
	  cardKind:(NSString*)aCardKind;

// Like @"Equivalent"
@property (readonly) NSString *name;

// A cross-language property connects between a word in one language 
// and a word in the native language.
@property (readonly) BOOL crossLanguage;

// A card kind to which this relation applies.
// Generally it's actually a prefix, like @"Verb-" which would
// then apply to all verbs.
@property (readonly) NSString *cardKind;

@end

@interface BaseLanguage : NSObject <Language> {
	NSString *name;
	NSString *identifier;
	NSString *keyboardIdentifier;
	NSDictionary *plist;
	NSMutableArray *cardKinds;
	NSMutableArray *relations;
	NSMutableArray *grammarRules;
	int languageVersion;
}

- initFromPlistNamed:(NSString*)plistName
			inBundle:(NSBundle*)bundle;

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

#pragma mark -
#pragma mark Plist Expansion Rules

// Language Rules can be defined in a plist file using strings, dictionaries, and arrays.  
// These can be used to structure the rules hierarchically.  The definition is
// eventually expanded into a flat list using @selector(expandGrammarRules).  
//
// The expansions proceeds as follows:
//
//    strings expand into OxArr(self)
//
//    arrays expand by flattening their contents.  Generally used for independent
//    categories like verbs, nouns, and adjectives.
//
//    dictionaries expand by expanding the value of each key and forming
//    all combinations using one value from each key.  This allows to combine
//    orthogonal facets, like tense (past, present) and person (1, 2, 3) for verbs.

@interface NSString (LanguagePlistExpansion)
- (NSArray*)expandLanguageDefn;
@end

@interface NSDictionary (LanguagePlistExpansion)
- (NSArray*)expandLanguageDefn;
@end

@interface NSArray (LanguagePlistExpansion)
- (NSArray*)expandLanguageDefn;
@end