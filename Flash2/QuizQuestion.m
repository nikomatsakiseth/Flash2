//
//  QuizQuestion.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuizQuestion.h"
#import "QuizCard.h"
#import "Model.h"

@implementation QuizQuestion

- initWithTitle:(NSString*)title subTitle:(NSString*)subTitle quizCards:(NSArray*)quizCards
{
	if ((self = [super init])) {
		m_title = title;
		m_subTitle = subTitle;
		m_quizCards = quizCards;
	}
	return self;
}

@synthesize title = m_title;
@synthesize subTitle = m_subTitle;
@synthesize quizCards = m_quizCards;

- (NSArray*) allRelatedCardDetails
{
	NSMutableArray *quizzedCards = [NSMutableArray array];	
	for (QuizCard *quizCard in m_quizCards)
		[quizzedCards addObjectsFromArray:quizCard.relatedCardDetails];
	return quizzedCards;	
}

- (NSArray*) allQuizzedCardsInManagedObjectContext:(NSManagedObjectContext*)mctx
{
	NSMutableArray *quizzedCards = [NSMutableArray array];	
	for (QuizCard *quizCard in m_quizCards)
		[quizzedCards addObjectsFromArray:[quizCard relatedCardsInManagedObjectContext:mctx]];
	return quizzedCards;
}

- (NSArray*) allQuizzedRules
{
	NSMutableArray *quizzedRules = [NSMutableArray array];
	for (QuizCard *quizCard in m_quizCards) {
		if (quizCard.relatedRule != nil)
			[quizzedRules addObject:quizCard.relatedRule];
	}
	return quizzedRules;
}

- (NSString*) description
{
	NSMutableString *result = [NSMutableString string];
	
	[result appendFormat:@"[QQ: %@ / %@", m_title, m_subTitle];
	for (QuizCard *quizCard in m_quizCards)
		[result appendFormat:@" / %@", quizCard];
	[result appendString:@"]"];
	
	return result;
}

@end
