//
//  QuizTabController.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuizTabController.h"
#import "Deck.h"
#import "QuizController.h"
#import "OxNSArray.h"
#import "OxDebug.h"

@implementation QuizTabController

@synthesize language = a_language;

- (void) awakeFromNib
{
	self.language = [[m_cardSet languages] _0];
	
	OxLog(@"self.language == %p %@", self.language, [self.language name]);	
}

- (IBAction) startQuiz:(id)sender {
	
	OxLog(@"self.language == %p %@", self.language, [self.language name]);
	
	Deck *deck = [[Deck alloc] initWithManagedObjectContext:[m_cardSet managedObjectContext] 
												   language:self.language];
	QuizController *qc = [[QuizController alloc] initWithLanguage:self.language
															 deck:deck
														  cardSet:m_cardSet];
	[m_cardSet addWindowController:qc];
	[qc start];
}

@end
