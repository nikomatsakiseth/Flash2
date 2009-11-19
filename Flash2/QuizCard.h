//
//  QuizCard.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Card.h"
#import "Language.h"

#define TOO_EASY   3
#define JUST_RIGHT 2
#define TOO_HARD   1

// Describes the text that appears on one side
// of a quiz card, as well as the keyboard that
// should be used to provide a response.  
//
// Each side of the card may or may not be editable:
// editable sides are sides that the user is expected
// to type in.  In that case, a simple text field is
// displayed.  Otherwise, if the side is non-editable,
// the `attributed` property is displayed.
//
// Editable card sides become non-editable once all answers
// have been provided.
@interface QuizCardSide : NSObject {
	NSString *expected;
	NSString *keyboardIdentifier;
	NSAttributedString *attributed;
	BOOL editable;
}

@property (copy) NSString *expected;              // The plain text on this side of the card.
@property (copy) NSString *keyboardIdentifier;    // Keyboard to use for user responses when editable.
@property (copy) NSAttributedString *attributed;  // Attributed string to display when `editable` is NO.
@property (readwrite) BOOL editable;              // Are we prompting the user for this side of the card?
@end

// Describes information about a card that
// did or could have been used to determine
// the answer to a quiz question.  For example,
// if the quiz question asks for the past tense
// of a verb, then the `fromString` would be the
// text of the verb, and the `relationName` would be
// the appropriate relation for a card that describes
// the past tense.  Such a card may or may not exist:
// if it exists, then it was used to derive the answer.
// If it does not, the user could create one in order
// to customize a programatically derived answer.
@interface RelatedCardDetail : NSObject {
	NSString *a_fromString;
	NSString *a_relationName;
}
- initWithFromString:(NSString*)fromString relationName:(NSString*)relationName;
@property (readonly) NSString *fromString;
@property (readonly) NSString *relationName;
@end

// Each question during a quiz consists of multiple QuizCards. 
// Each `QuizCard` contains two sides (`fromSide`, `toSide`) and a
// relation between them (the `promptRelationName`).  Generally, one of the
// two sides is editable.
//
// In addition to the display information, a `QuizCard` contains
// details about the cards or grammar rules that it is testing.
// This data is stored in `relatedRule` and `relatedCardDetails`.
@interface QuizCard : NSObject {
	Language *m_language;

	NSString *a_relatedRule;
	NSArray *a_relatedCardDetails;
		
	QuizCardSide *a_fromSide;
	NSString *a_promptRelationName;
	QuizCardSide *a_toSide;	
	
	NSString *a_userAnswer;
	
	int a_wrong;
}

// Full constructor allowing every aspect of the card to be 
// customized.
- initWithStrings:(NSString*[])string
		editables:(BOOL[])editables
promptRelationName:(NSString*)promptRelationName
	  keyboardIds:(NSString*[])kbIds
relatedCardDetails:(NSArray*)relatedCardDetails
	  relatedRule:(NSString*)relatedRule
		 language:(Language*)language;

// Shortcut constructor that takes ALMOST all details from `card`.
- initWithCard:(Card*)card
	   strings:(NSString*[])strings
 promptingLeft:(BOOL)promptLeft
	  language:(Language*)language;

// Shortcut constructor that takes all details from `card`.
- initWithCard:(Card*)card
 promptingLeft:(BOOL)promptLeft
	  language:(Language*)language;

@property (readonly) QuizCardSide *fromSide;       // displayed on left-hand side of GUI
@property (readonly) QuizCardSide *toSide;         // displayed on right-hand side of GUI
@property (readonly) NSString *promptRelationName; // displayed in the middle in GUI
@property (copy) NSString *userAnswer;             // bound to and set by GUI

// Initially NO, set by [check] message.
// Use int instead of BOOL so that it's 32 bits wide
// and can be used with HOM.
@property (readwrite) int wrong;

// Any card/rule that were used to predict this answer.
// Incorrect answers will affect when this card/rule will be
// asked next.  Both of these properties may be nil.
@property (retain) NSArray *relatedCardDetails;
@property (retain) NSString *relatedRule;

// Checks whether the current answers are wrong/correct.
// Returns YES if they are WRONG, and updates the
// display to show the correct answer.
- (void) check;

// Returns any related cards from the given context.
- (NSArray*) relatedCardsInManagedObjectContext:(NSManagedObjectContext*)mctx;

// Adjust the time durations, depending on the
// level provided.  It should be 1-3 based on
// constants defined above.
- (void) mark:(int)level managedObjectContext:(NSManagedObjectContext*)mctx;

@end
