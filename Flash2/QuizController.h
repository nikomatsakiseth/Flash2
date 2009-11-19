//
//  QuizController.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Language.h"
#import "Deck.h"
#import "CardSet.h"
#import "FlashTextView.h"
#import "KeyboardSelector.h"

@class QuizController;

@interface QuizEditCardsController : NSObject {
	QuizController *m_quizController;
	NSArray *a_editCards;
}

- initWithQuizController:(QuizController*)quizController quizQuestion:(QuizQuestion*)quizQuestion;

@property (retain) NSArray *editCards;

- (void) beginEditMode;
- (void) endEditMode;

@end

@interface QuizController : NSWindowController {
	IBOutlet NSBox *m_box;
	IBOutlet KeyboardSelector *m_kbSel;	
	IBOutlet NSProgressIndicator *m_indicator;
	
	NSDate *m_startTime;
	Deck *m_deck;
	NSManagedObjectContext *m_mctx;
	CardSet *m_cardSet;

	// Review Mode:
	// 
	//   As we ask questions, we accumulate "too hard" cards into
	//   the "tooHardCards" array.  Once this array reaches a
	//   sufficient length, we enter REVIEW mode.  In this mode,
	//   we simply display all of the cards that need review for
	//   the user and wait for them to press DONE, which ends
	//   the quiz.
	BOOL m_review;
	NSMutableArray *m_tooHardCards;

	// Edit Mode:
	//
	//   After a user sees the correct answers, they may elect to
	//   EDIT the cards in question.  Usually this is because they
	//   noticed a typo or other mistake in their flash cards.
	//   This drops us into a mode where all the cards that were used
	//   or could have been used to make the question are displayed.
	//   The user may edit the strings in any way they choose.
	//   They click DONE when finished, and the cards are updated in
	//   place.  The quiz then returns into QUIZ mode.
	QuizEditCardsController *m_edit;

	// Observed by the GUI:
	Language *a_language;
	BOOL a_doneEnabled;                // DONE button enabled?
	BOOL a_levelsEnabled;              // TOO EASY, JUST RIGHT, TOO HARD, EDIT, enabled?
	QuizQuestion *a_currentQuestion;
}

// Main interface:
- initWithLanguage:(Language*)language deck:(Deck*)deck cardSet:(CardSet*)cardSet;
- (void) start;

// Nib/internal interface:
@property (readonly) NSBox *box;
@property (readonly) Language *language;
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (retain) QuizQuestion *currentQuestion;

- (void) nextQuestion;
- (void) buildQuestionInterface;

@property (readwrite) BOOL doneEnabled;
- (IBAction) done:(id)sender;

@property (readwrite) BOOL levelsEnabled;
- (IBAction) tooEasy:(id)sender;
- (IBAction) justRight:(id)sender;
- (IBAction) tooHard:(id)sender;
- (IBAction) editCards:(id)sender;

// Edit mode:

@end
