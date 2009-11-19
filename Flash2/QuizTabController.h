//
//  QuizTabController.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CardSet.h"
#import "Language.h"

// controls the Quiz tab in the main window,
// not the quizzes themselves.
@interface QuizTabController : NSObject {
	IBOutlet CardSet *m_cardSet;
	Language *a_language;
}

@property (retain) Language *language; // bound in GUI

- (IBAction) startQuiz:(id)sender;

@end
