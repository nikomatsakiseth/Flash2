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
	 relations:(NSArray*)rels
  grammarRules:(NSArray*)rules
quizConfigurationKeys:(NSArray*)keys
  keyboardIdentifier:(NSString*)keyboardIdentifier;

// Not part of the required interface.
- initFromPlistNamed:(NSString*)plistName
			inBundle:(NSBundle*)bundle;

// Defines the protocol version supported by
// this language definition.  For now there is
// only one version, so return FLASH2_PROTOCOL_V1.
- (NSString*) protocolVersion;

// The version of this language definition.
- (int) languageVersion;

// If a data file is loaded from an older version
// of this language, then this function will be
// invoked to upgrade it. The 'data' dictionary has
// the keys specified above.
- (NSDictionary*) upgradeData:(NSDictionary*)data
		  fromLanguageVersion:(int)version;

// The name of this language as it should be
// displayed to the user.
- (NSString*) name;

// A unique identifier identifying this
// language module.  For example,
// com.smallcultfollowing.Greek
- (NSString*) identifier;

// The identifier of the keyboard to use when editing words in this language.
// Example, @"com.apple.keylayout.Greek"
- (NSString*) keyboardIdentifier;

// Returns an array of NSString* representing the names of all
// possible grammar rules.  When the user's data is loaded from
// disk, the names of any expired grammar rules will be cross-checked
// against this list.
- (NSArray*) grammarRules;

// Returns an array of relation objects.
- (NSArray*) relations;

// Returns the relation object with the given name, or nil.
- (Relation*) relationNamed:(NSString*)name;

// Returns an array of strings representing information to ask the user for
// when configuring a quiz.  
- (NSArray*) quizConfigurationKeys;

// Returns an array of QQFs, which are used during quizzes to construct
// questions based on the expired cards and rules.
- (NSArray*) quizQuestionFactories;

// Languages may optionally implement a gui portion.
// Then when users click on "transform word" the
// openGuiForCard: method is invoked.  The createGuiController:
// message should create a new controller, using the given 
// managed object context for any queries.  This controller may optionally
// respond to selectCard:, which will be sent whenever the user
// clicks the "conjugate" button
- (BOOL) supportsGui;                  // return YES if openGuiForCard: does something
- (NSWindowController*) createGuiController:(NSManagedObjectContext*)ctx;

@end

@interface Relation : NSObject {
	NSString *m_name;
	BOOL m_crossLanguage;
	Language *m_language;
}

// Not part of the required interface.
- initWithLanguage:(Language*)language name:(NSString*)name crossLanguage:(BOOL)crossLanguage;

// Language from which this relation originates.
@property (readonly) Language *language;

// Like @"Equivalent"
@property (readonly) NSString *name;

// A cross-language property connects between a word in one language 
// and a word in the native language.
@property (readonly) BOOL crossLanguage;

// Keyboard identifier to use when editing toStrings for
// cards with this relation.  Depends on whether the
// relation is cross language or not.
@property (readonly) NSString *toStringKeyboardIdentifier;
@end

@interface QuizQuestionFactory : NSObject {
}

// Tries to make a question that tests 'rule'.  A deck is provided
// to obtain words.  Returns nil if this factory is not the correct kind for that combination.
- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck;

// Tries to make a question that tests the relation named 'relationName', using the word 'word'.
// Returns nil if this factory is not the correct kind for that combination.
- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Card*)word deck:(Deck*)deck;

@end

#pragma mark -
#pragma mark Plist Expansion Rules

// Language Rules can be defined in a plist file using strings, dictionaries, and arrays.  
// These can be used to structure the rules hierarchically.  The definition is
// eventually expanded into a flat list using @selector(expandGrammarRules).  
//
// The expansions proceeds as follows:
//
//    strings expand into themselves
//
//    dictionaries expand into the combination of all of their expanded values,
//    using the key as a prefix.  This allows one to define independent categories,
//    like verb, noun, and adjective.
//
//    arrays expand by expanding each item in the array and then combining them
//    multiplicatively.  Therefore, an array with 2 items would combine each
//    item the expanded version of array[0] with each item in the expanded
//    version of array[1].  This allows one to define orthogonal facets, like
//    tense and plural for verbs.

@interface NSString (LanguagePlistExpansion)
- (NSArray*) expandGrammarRules;
@end

@interface NSDictionary (LanguagePlistExpansion)
- (NSArray*) expandGrammarRules;
@end

@interface NSArray (LanguagePlistExpansion)
- (NSArray*) expandGrammarRules;
@end