//
//  QuizController.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuizController.h"
#import "Config.h"
#import "OxNSArray.h"
#import "QuizQuestion.h"
#import "QuizCard.h"
#import "Ox.h"
#import "OxNSObject.h"
#import "OxNSTextField.h"
#import "OxHom.h"
#import "CardUIBuilder.h"
#import "FlashTextField.h"
#import "Model.h"
#import "OxDebug.h"

@implementation QuizController

@synthesize currentQuestion = a_currentQuestion;
@synthesize doneEnabled = a_doneEnabled;
@synthesize levelsEnabled = a_levelsEnabled;
@synthesize box = m_box;
@synthesize language = a_language;
@synthesize managedObjectContext = m_mctx;

- initWithLanguage:(Language*)language deck:(Deck*)deck cardSet:(CardSet*)cardSet
{
	if ((self = [super initWithWindowNibName:@"Quiz"])) {
		m_deck = deck;
		a_language = language;
		a_doneEnabled = NO;
		a_levelsEnabled = NO;
		m_tooHardCards = [NSMutableArray array];
		m_cardSet = cardSet;
		m_mctx = [cardSet managedObjectContext];
		[m_kbSel setCardSet:m_cardSet];
	}
	return self;
}

- (void) start {
	[[self window] makeKeyAndOrderFront:self];
	[self nextQuestion];
}

- (void) allDone 
{
	[[self window] orderOut:self];
	[m_cardSet removeWindowController:self];
	[[self window] close];
	[self close];
}

// Adds NSTextFields etc to represent the
// cards of the current question.
- (void) buildQuestionInterface {
	NSArray *quizCards = self.currentQuestion.quizCards;
	CardUIBuilder *builder = [[CardUIBuilder alloc] initWithWindow:[self window] delegate:self];
//	[builder resizeScrollView:m_scroller toCards:[quizCards count] relationClass:[NSTextField class]];
	[builder resizeBox:m_box toCards:[quizCards count] relationClass:[NSTextField class]];
}

// invoked by configureRow:views: as UI is built
- (void) configureTextField:(FlashTextField*)tf 
				   quizCard:(QuizCard*)quizCard
					   side:(NSString*)side 
{
	NSString *editable = [side stringByAppendingString:@".editable"];
	NSString *attributed = [side stringByAppendingString:@".attributed"];
	NSDictionary *opts = OxDict(OxInt(1) FOR NSContinuouslyUpdatesValueBindingOption);
	if (![[quizCard valueForKeyPath:editable] boolValue]) {
		[tf bind:@"value" toObject:quizCard withKeyPath:attributed options:opts];
		[tf configureIntoLabel];
	} else {
		[tf bind:@"value" toObject:quizCard withKeyPath:@"userAnswer" options:opts];
		[tf bind:@"keyboardIdentifier" toObject:quizCard withKeyPath:[side stringByAppendingString:@".keyboardIdentifier"] options:nil];
	}
}

// invoked by CardUIBuilder for each row:
- (void) configureRow:(int)row views:(NSArray*)views
{
	NSArray *quizCards = self.currentQuestion.quizCards;
	QuizCard *card = [quizCards objectAtIndex:row];
	[self configureTextField:[views _0] quizCard:card side:@"fromSide"];
	[[views _1] configureIntoLabel];
	[[views _1] bind:@"value" toObject:card withKeyPath:@"promptRelationName" options:nil]; 
	[self configureTextField:[views _2] quizCard:card side:@"toSide"];
}	

- (BOOL) adjustProgressMeter
{
	int minLength = minimumQuizLength();
	int maxLength = maximumQuizLength();
	int expiredRemaining = [m_deck countOfExpiredItemsRemaining];

	int relLength = (expiredRemaining == 0 ? minLength : maxLength);
	int mistakes = [m_tooHardCards count];
	
	OxLog(@"mistakes = %d, expiredRemaining = %d, minLength = %d, maxLength = %d, relLength = %d",
		  mistakes, expiredRemaining, minLength, maxLength, relLength);
	if (mistakes > relLength) {
		[m_indicator setDoubleValue:1.0]; // 100% done
		return NO; 
	}

	double total = minLength + fmin(maxLength - minLength, expiredRemaining);
	double current = mistakes;
	[m_indicator setDoubleValue:current / total];
	return YES;
}

- (void) nextQuestion {
	if ([self adjustProgressMeter]) // asked enough questions?
		self.currentQuestion = [m_deck nextQuizQuestion]; // not yet
	else
		self.currentQuestion = nil;  // yep
	
	if (self.currentQuestion != nil) {
		m_startTime = [NSDate date];
	} else if (![m_tooHardCards isEmpty]) {
		// out of questions, toss up the cards for review
		self.currentQuestion = [[QuizQuestion alloc] initWithTitle:@"Please Review" 
														  subTitle:@"" 
														 quizCards:m_tooHardCards];
		
		m_review = YES;
	} else {
		[self allDone];
	}

	[self buildQuestionInterface];
		
	self.doneEnabled = YES;
	self.levelsEnabled = NO;
}

- (IBAction) done:(id)sender {
	if (m_review) {
		[self allDone];
		return;
	}
	
	if (m_edit) {
		[m_edit endEditMode];
		m_edit = nil;
		return;
	}
	
	self.doneEnabled = NO;
	self.levelsEnabled = YES;
	
	[[self window] makeFirstResponder:nil];
	
	[[self.currentQuestion.quizCards performForEach] check];

	// rebuild question inferface now that things are no longer editable
	[self buildQuestionInterface];	

	// Check if they got everything right within the too easy interval.
	// If so, just automatically mark it as too easy.
	NSArray *wrongCards = OxFilter(self.currentQuestion.quizCards, wrong);	
	if ([wrongCards isEmpty]) {
		NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:m_startTime];
		if (elapsed < tooEasyInterval()) {
			[[self.currentQuestion.quizCards performForEach] mark:TOO_EASY 
									  managedObjectContext:m_mctx];
			[self nextQuestion];
			return;
		}
	}
	
	// Wait until the user indicates how hard it was.	
}

- (void) mark:(int)level {
	NSArray *wrongCards = OxFilter(self.currentQuestion.quizCards, wrong);	
	
	if ([wrongCards isEmpty])
		[[self.currentQuestion.quizCards performForEach] mark:level managedObjectContext:m_mctx];
	else {
		NSArray *rightCards = [self.currentQuestion.quizCards arrayByRemovingObjectsFromArray:wrongCards];
		int rightLevel = level+1; // for now, always mark correct cards one level higher...
		if (rightLevel > TOO_EASY) rightLevel = TOO_EASY; // ... but saturate of course
		[[wrongCards performForEach] mark:level managedObjectContext:m_mctx];
		[[rightCards performForEach] mark:rightLevel managedObjectContext:m_mctx];
		
		// remember the ones that were too hard for later
		if (level == TOO_HARD)
			[m_tooHardCards addObjectsFromArray:wrongCards];
	}
	
	[self nextQuestion];
}

- (IBAction) tooEasy:(id)sender {
	[self mark:TOO_EASY];
}

- (IBAction) justRight:(id)sender {
	[self mark:JUST_RIGHT];
}

- (IBAction) tooHard:(id)sender {
	[self mark:TOO_HARD];
}

- (IBAction) editCards:(id)sender {
	// Create cards to be edited:
	m_edit = [[QuizEditCardsController alloc] initWithQuizController:self quizQuestion:self.currentQuestion];
	[m_edit beginEditMode];
}

@end

@implementation QuizEditCardsController

- initWithQuizController:(QuizController*)quizController quizQuestion:(QuizQuestion*)quizQuestion 
{
	if ((self = [super init])) {
		m_quizController = quizController;
		Language *language = quizController.language;
		NSManagedObjectContext *mctx = m_quizController.managedObjectContext;
		NSMutableArray *editCards = [NSMutableArray array];	
		
		for (RelatedCardDetail *detail in [quizQuestion allRelatedCardDetails]) {
			Relation *relation = [language relationNamed:detail.relationName];
			NSString *toStringKeyboardIdentifier = relation.toStringKeyboardIdentifier;
			
			// Check if card(s) already exists.
			NSArray *existingCards = [mctx cardsWithFromString:detail.fromString relationName:detail.relationName language:language];
			for (Card *existingCard in existingCards) {
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:detail forKey:@"detail"];
				[dict setObject:existingCard forKey:@"existingCard"];
				[dict setObject:detail.fromString forKey:@"fromString"];			
				[dict setObject:detail.relationName forKey:@"relationName"];
				[dict setObject:existingCard.toString forKey:@"toString"];
				if (toStringKeyboardIdentifier)
					[dict setObject:toStringKeyboardIdentifier forKey:@"toKeyboardIdentifier"];
				[editCards addObject:dict];
			}
			
			// Add an option to add a new card if no cards already exist.
			if ([existingCards isEmpty]) {
				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:detail forKey:@"detail"];
				[dict setObject:detail.fromString forKey:@"fromString"];			
				[dict setObject:detail.relationName forKey:@"relationName"];
				[dict setObject:@"" forKey:@"toString"];
				if (toStringKeyboardIdentifier)
					[dict setObject:toStringKeyboardIdentifier forKey:@"toKeyboardIdentifier"];
				[editCards addObject:dict];
			}
			
		}		
		self.editCards = editCards;		
	}
	return self;
}

- (void) beginEditMode
{
	m_quizController.levelsEnabled = NO;
	m_quizController.doneEnabled = YES;	
	
	NSWindow *window = [m_quizController window];
	NSBox *box = m_quizController.box;
	CardUIBuilder *builder = [[CardUIBuilder alloc] initWithWindow:window delegate:self];
//	[builder resizeScrollView:scroller toCards:[self.editCards count] relationClass:[NSTextField class]];	
	[builder resizeBox:box toCards:[self.editCards count] relationClass:[NSTextField class]];	
}

// invoked by CardUIBuilder for each row:
- (void) configureRow:(int)row views:(NSArray*)views
{
	NSMutableDictionary *editCard = [self.editCards objectAtIndex:row];
	NSDictionary *opts = OxDict(OxInt(1) FOR NSContinuouslyUpdatesValueBindingOption);
	
	[[views _0] bind:@"value" toObject:editCard withKeyPath:@"fromString" options:opts];
	[[views _0] bind:@"keyboardIdentifier" toObject:m_quizController withKeyPath:@"language.keyboardIdentifier" options:opts];

	[[views _1] bind:@"value" toObject:editCard withKeyPath:@"relationName" options:opts];
	[[views _1] configureIntoLabel];
	
	[[views _2] bind:@"value" toObject:editCard withKeyPath:@"toString" options:opts];
	[[views _2] bind:@"keyboardIdentifier" toObject:editCard withKeyPath:@"toStringKeyboardIdentifier" options:opts];
}

@synthesize editCards = a_editCards;

- (void) endEditMode
{
	// Make changes:
	NSManagedObjectContext *mctx = m_quizController.managedObjectContext;
	for (NSMutableDictionary *editCard in self.editCards) {
		Card *existingCard = [editCard objectForKey:@"existingCard"]; // this key may not be present
		NSString *fromString = [editCard objectForKey:@"fromString"];
		NSString *toString = [editCard objectForKey:@"toString"];
		
		if ([toString isEqual:@""])
			toString = nil; // easier to test for
				
		if (existingCard == nil && toString == nil)
			continue;
		
		if (existingCard != nil && toString == nil) {
			// Delete existing card.
			[mctx deleteObject:existingCard];
			continue;
		}
		
		if (existingCard != nil) {
			// Potentially edit existing card.
			if (![existingCard.fromString isEqual:fromString])
				[existingCard setFromString:fromString];
			if (![existingCard.toString isEqual:toString])
				[existingCard setToString:toString];
			continue;
		}
		
		// Create new card.
		NSString *relationName = [editCard objectForKey:@"relationName"];
		[mctx createNewCardFromString:fromString 
						 relationName:relationName 
							 toString:toString 
							 language:m_quizController.language];
	}
	
	m_quizController.levelsEnabled = YES;
	m_quizController.doneEnabled = NO;	
	[m_quizController buildQuestionInterface];
}

@end

