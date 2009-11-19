//
//  Deck.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Word.h"
#import "Language.h"

// The Deck is used to track which cards/rules need to 
// be asked about.  It is provided with a 
// set of quiz question factories that it uses to make
// questions.
@interface Deck : NSObject {
	NSMutableArray *m_expiredCards;
	NSMutableArray *m_expiredRules;
	NSMutableArray *m_newCards;
	NSMutableArray *m_newRules;
	NSArray *m_quizQuestionFactories;
	Language *m_language;
	NSManagedObjectContext *m_ctx;
	
	NSMutableArray *m_remainingCards;
}

- initWithManagedObjectContext:(NSManagedObjectContext*)ctx
					  language:(Language*)language;

@property (readonly) Language *language;

- (int) countOfExpiredItemsRemaining;

// Tries to create a new quiz question.
// Returns nil if there are no more things to ask
// about.
- (QuizQuestion*) nextQuizQuestion;

// Used by QQFs if they need more than one word 
// to construct a question.  Returns another
// eligible word.  May return nil and
// may return the same word twice.
- (Word*) nextWord;

@end
