//
//  Deck.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Deck.h"
#import "OxNSArray.h"
#import "Queries.h"
#import "CardHistory.h"
#import "GrammarRuleHistory.h"
#import "OxCoreData.h"
#import "QuizQuestion.h"
#import "OxDebug.h"§	

@implementation CardHistory (DeckAdditions)
- (void) addExpiredCardsTo:(NSMutableArray*)array { [array addObject:self.card]; }
- (void) addExpiredRulesTo:(NSMutableArray*)array { }
@end

@implementation GrammarRuleHistory (DeckAdditions)
- (void) addExpiredCardsTo:(NSMutableArray*)array { }
- (void) addExpiredRulesTo:(NSMutableArray*)array { [array addObject:self.grammarRuleName]; }
@end

@implementation Deck

@synthesize language = m_language;

- initWithManagedObjectContext:(NSManagedObjectContext*)ctx
					  language:(Language*)language
{
	if ((self = [super init])) {
		OxLog(@"New Deck for language %@", [language name]);
		m_ctx = ctx;
		m_language = language;
				
		m_expiredCards = [NSMutableArray array];
		m_expiredRules = [NSMutableArray array];		
		NSArray *expiredHistories = [ctx mostRecentHistoriesExpiringBefore:[NSDate date] language:language];
		[expiredHistories makeObjectsPerformSelector:@selector(addExpiredCardsTo:) withObject:m_expiredCards];
		[expiredHistories makeObjectsPerformSelector:@selector(addExpiredRulesTo:) withObject:m_expiredRules];
		
		m_newCards = [NSMutableArray arrayWithArray:[ctx cardsWithNoHistoryInLanguage:language]];
		
		m_newRules = [NSMutableArray arrayWithArray:[language grammarRules]];
		NSArray *grammarRuleHistories = [ctx allObjectsOfEntityType:E_GRAMMAR_RULE_HISTORY];
		[m_newRules removeObjectsInArray:[grammarRuleHistories valueForKey:K_GRAMMAR_RULE_NAME]];
		
		m_quizQuestionFactories = [language quizQuestionFactories];
		
		m_remainingCards = [NSMutableArray array]; // reinitialized in each call to nextQuizQuestion:
	}
	return self;
}

- (int) countOfExpiredItemsRemaining
{
	return [m_expiredCards count] + [m_expiredRules count];
}

- (void) cardDealt:(Card*)card {
	[m_expiredCards removeObject:card];
	[m_newCards removeObject:card];
}

- (void) initRemainingCards {
	m_remainingCards = [NSMutableArray array];
	[m_remainingCards addObjectsFromArray:m_expiredCards];
	[m_remainingCards addObjectsFromArray:m_newCards];
}

- (int) sizeOfIntersectionOf:(NSArray*)array1 with:(NSArray*)array2
{
	int size = 0;
	for (id object in array2) {
		if ([array1 containsObject:object])
			size++;
	}
	return size;
}

- (QuizQuestion*) pickMostSuitable:(NSArray*)qqs
{
	if ([qqs isEmpty])
		return nil;
	
	// find the question that asks about the most eligible cards and rules,
	// but the minimum of other stuff
	int maxMatched = -1;
	int maxQuizzed = -1;
	QuizQuestion *maxQq = nil;
	
	OxLog(@"Finding most suitable question of %d candidates:", [qqs count]);

	NSArray *eligibleCards = [m_expiredCards arrayByAddingObjectsFromArray:m_newCards];
	NSArray *eligibleRules = [m_expiredRules arrayByAddingObjectsFromArray:m_newRules];
	for (QuizQuestion *qq in qqs) {
		NSArray *quizzedCards = [qq allQuizzedCardsInManagedObjectContext:m_ctx];
		NSArray *quizzedRules = [qq allQuizzedRules];
		int quizzed = [quizzedCards count] + [quizzedRules count];
		
		int matchedCards = [self sizeOfIntersectionOf:eligibleCards with:quizzedCards];
		int matchedRules = [self sizeOfIntersectionOf:eligibleRules with:quizzedRules];
		int matched = matchedCards + matchedRules;		
		
		OxLog(@"  question: %@", qq);
		if (matched > maxMatched || (matched == maxMatched && quizzed < maxQuizzed))
		{
			OxLog(@"  question matched %d and quizzed %d, beats old best of %d and %d", 
				  matched, quizzed, maxMatched, maxQuizzed);
			
			maxQq = qq;
			maxMatched = matched;
			maxQuizzed = quizzed;
		} else {
			OxLog(@"  question matched %d and quizzed %d, not best, which has %d and %d", 
				  matched, quizzed, maxMatched, maxQuizzed);
		}
		
	}
	
	return maxQq;
}

- (QuizQuestion*) createQuestionForRule:(NSString*)rule
{
	OxLog(@"Deck: trying to create question for rule %@", rule);
	
	[self initRemainingCards];
	
	NSMutableArray *qqs = [NSMutableArray array];
	for (id qqf in m_quizQuestionFactories) {
		QuizQuestion *qq = [qqf makeQuestionForRule:rule deck:self];
		if (qq != nil) 
			[qqs addObject:qq];
	}
	return [self pickMostSuitable:qqs];
}

- (QuizQuestion*) createQuestionForCard:(Card*)card
{
	OxLog(@"Deck: trying to create question for card %@", card);
	
	[self initRemainingCards];
	[m_remainingCards removeObject:card];
	
	Word *word = [[Word alloc] initWithCard:card];
	NSMutableArray *qqs = [NSMutableArray array];
	for (id qqf in m_quizQuestionFactories) {
		QuizQuestion *qq = [qqf makeQuestionForRelationNamed:[card relationName] ofWord:word deck:self];
		if (qq != nil) 
			[qqs addObject:qq];
	}
	return [self pickMostSuitable:qqs];
}

- (QuizQuestion*) nextQuizQuestion 
{
	// First, decide whether we will ask about a GRAMMATICAL RULE or 
	// about a CARD.  For now we just give strict preference.
	
	QuizQuestion *qq = nil;
	int index;
	
	OxLog(@"--------------------------------------------------");
	
	OxLog(@"Expired Rules");
	index = 0;
	while (!qq && index < [m_expiredRules count])
		qq = [self createQuestionForRule:[m_expiredRules objectAtIndex:index++]];
	
	OxLog(@"Expired Cards");
	index = 0;
	while (!qq && index < [m_expiredCards count])
		qq = [self createQuestionForCard:[m_expiredCards objectAtIndex:index++]];
	
	OxLog(@"New Rules");
	index = 0;
	while (!qq && index < [m_newRules count])
		qq = [self createQuestionForRule:[m_newRules objectAtIndex:index++]];
	
	OxLog(@"New Cards");
	index = 0;
	while (!qq && index < [m_newCards count])
		qq = [self createQuestionForCard:[m_newCards objectAtIndex:index++]];

	// Remove any cards/rules that the final question actually asks:
	if (qq != nil) {
		NSArray *quizzedCards = [qq allQuizzedCardsInManagedObjectContext:m_ctx];
		[m_expiredCards removeObjectsInArray:quizzedCards];
		[m_newCards removeObjectsInArray:quizzedCards];
		OxLog(@"Remove objects in: %@ yielding expired: %@ new: %@", quizzedCards, m_expiredCards, m_newCards);
		NSArray *quizzedRules = [qq allQuizzedRules];
		[m_expiredRules removeObjectsInArray:quizzedRules];
		[m_newRules removeObjectsInArray:quizzedRules];
		OxLog(@"Remove objects in: %@ yielding expired: %@ new: %@", quizzedRules, m_expiredRules, m_newRules);
	}
	
	return qq;
}

- (Word*) nextWord
{
	if ([m_remainingCards isEmpty])
		return nil;
	Card *card = [m_remainingCards objectAtIndex:0];
	[m_remainingCards removeObjectAtIndex:0];
	return [[Word alloc] initWithCard:card];
}
	
@end
