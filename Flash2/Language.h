//
//  LanguageDefn.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Various Quiz Model classes used in the
// interface:
@class Deck;
@class QuizQuestion;
@class Card;
@class Relation;

// Protocols for protocolVersion
#define FLASH2_PROTOCOL_V1 @"FLASH2_PROTOCOL_V1"

// Keys for upgradeData:fromLanguageVersion:
#define FLASH2_DATA_CARDS @"FLASH2_DATA_CARDS" // NSArray[Card]
#define FLASH2_CARD_HISTORIES @"FLASH2_CARD_HISTORIES" // NSArray[CardHistory]
#define FLASH2_GRAMMAR_RULE_HISTORIES @"FLASH2_GRAMMAR_RULE_HISTORIES" // NSArray[GrammmarRuleHistory]

// Array of all defined languages.
NSArray *allLanguages();

// The protocol to be supported by language
// definitions.
@protocol Language <NSObject>

// Defines the protocol version supported by
// this language definition.  For now there is
// only one version, so return FLASH2_PROTOCOL_V1.
- (NSString*)protocolVersion;

// The version of this language definition.
- (int)languageVersion;

// If a data file is loaded from an older version
// of this language, then this function will be
// invoked to upgrade it. The 'data' dictionary has
// the keys specified above.
- (NSDictionary*)upgradeData:(NSDictionary*)data
		 fromLanguageVersion:(int)version;

// The name of this language as it should be
// displayed to the user.
- (NSString*)name;

// A unique identifier identifying this
// language module.  For example,
// com.smallcultfollowing.Greek
- (NSString*)identifier;

// The identifier of the keyboard to use when editing words in this language.
// Example, @"com.apple.keylayout.Greek"
- (NSString*)keyboardIdentifier;

// An Array of strings with the names of card kinds.
// For example, @"Noun", @"Verb", @"Other"
- (NSArray*)cardKinds;

// Given the text of a card, guess an appropriate kind.
// The user can always change it later.
- (NSString*)guessKindOfText:(NSString*)aText;

// The names of relations appropriate to a card of kind 'cardKind'.
- (NSArray*)relationNamesForCardKind:(NSString*)cardKind;

// All relation names which are recognized by this language.
- (NSArray*)allRelationNames;

// Returns true if the relation is a 'cross-language' relation.
// For example, the Equivalent relation maps a word in this 
// language to one in the user's native language, and would therefore
// return YES.  This is used to guide the keyboard selection.
- (BOOL)isCrossLanguageRelation:(NSString*)relationName;

// Returns an array of NSString* representing the names of all
// possible grammar rules.  When the user's data is loaded from
// disk, the names of any expired grammar rules will be cross-checked
// against this list.
- (NSArray*)grammarRules;

// Attempts to automatically derive a property for the given relation name
// and the given card.  May return nil if it was not able to for any reason, 
// such as the relation name is not recognized.
- (NSString*)autoPropertyForCard:(Card*)aCard relationName:(NSString*)aRelationName;

@end


// Base classes defining how a Flash2 language definition
// behaves.  You only need to following the documented
// interface, of course.  However, these base classes
// may be useful to you in any case.

@interface Language : NSObject {
	NSDictionary *m_plist; // if not initialized from a plist, then nil
	NSString *m_name;
	NSString *m_identifier;
	NSArray *m_relations;
	NSArray *m_grammarRules;
	NSArray *m_quizConfigurationKeys;
	NSString *m_keyboardIdentifier;
}

// Not part of the required interface.  Returns an array of languages
// including both built-in languages and any languages loaded from plug-ins.
+ (NSArray*) languages;

// Not part of the required interface.
- initWithName:(NSString*)name
	identifier:(NSString*)identifier
	 cardKinds:(NSArray*)cardKinds
  grammarRules:(NSArray*)rules
quizConfigurationKeys:(NSArray*)keys
  keyboardIdentifier:(NSString*)keyboardIdentifier;

// Not part of the required interface.
- initFromPlistNamed:(NSString*)plistName
			inBundle:(NSBundle*)bundle;

// Defines the protocol version supported by
// this language definition.  For now there is
// only one version, so return FLASH2_PROTOCOL_V1.
- (NSString*)protocolVersion;

// The version of this language definition.
- (int)languageVersion;

// If a data file is loaded from an older version
// of this language, then this function will be
// invoked to upgrade it. The 'data' dictionary has
// the keys specified above.
- (NSDictionary*)upgradeData:(NSDictionary*)data
		 fromLanguageVersion:(int)version;

// The name of this language as it should be
// displayed to the user.
- (NSString*)name;

// A unique identifier identifying this
// language module.  For example,
// com.smallcultfollowing.Greek
- (NSString*)identifier;

// The identifier of the keyboard to use when editing words in this language.
// Example, @"com.apple.keylayout.Greek"
- (NSString*)keyboardIdentifier;

// An Array of strings with the names of card kinds.
// For example, @"Noun", @"Verb", @"Other"
- (NSArray*)cardKinds;

// Given the text of a card, guess an appropriate kind.
// The user can always change it later.
- (NSString*)guessKindOfText:(NSString*)aText;

// The names of relations appropriate to a card of kind 'cardKind'.
- (NSArray*)relationNamesForCardKind:(NSString*)cardKind;

// All relation names which are recognized by this language.
- (NSArray*)allRelationNames;

// Returns true if the relation is a 'cross-language' relation.
// For example, the Equivalent relation maps a word in this 
// language to one in the user's native language, and would therefore
// return YES.  This is used to guide the keyboard selection.
- (BOOL)isCrossLanguageRelation:(NSString*)relationName;

// Returns an array of NSString* representing the names of all
// possible grammar rules.  When the user's data is loaded from
// disk, the names of any expired grammar rules will be cross-checked
// against this list.
- (NSArray*) grammarRules;

// Returns the relation object with the given name, or nil.
- (Relation*) relationNamed:(NSString*)name;

@end

@interface QuizQuestionFactory : NSObject {
}

// Tries to make a question that tests 'rule'.  A deck is provided
// to obtain words.  Returns nil if this factory is not the correct kind for that combination.
- (QuizQuestion*)makeQuestionForRule:(NSString*)rule deck:(Deck*)deck;

// Tries to make a question that tests the relation named 'relationName', using the word 'word'.
// Returns nil if this factory is not the correct kind for that combination.
- (QuizQuestion*)makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Card*)word deck:(Deck*)deck;

@end

