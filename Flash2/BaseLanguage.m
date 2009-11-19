//
//  BaseLanguage.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Ox.h"
#import "BaseLanguage.h"
#import "Deck.h"
#import "QuizCard.h"
#import "QuizQuestion.h"
#import "OxNSArray.h"
#import "OxDebug.h"

@implementation WordCategory 

- initWithWord:(Word*)word language:(id)lang {
	if ((self = [super init])) {
		m_word = word;
		m_lang = lang;
	}
	return self;
}

@end

@implementation BaseLanguage

- (NSArray*) conjugate:(Word*)word person:(int)person plural:(BOOL)plural
{
	return nil; // should be overridden most likely!
}

- (NSArray*) tenseNames
{
	return [NSArray array];
}

- (NSArray*) relationNamesForTense:(int)tense person:(int)person plural:(int)plural
{
	return OxAbstract();
}

@end

@implementation EquivalentQuizQuestionFactory

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck {
	return nil; // EQUIVALENT factory only works off of cards.
}

- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Word*)word deck:(Deck*)deck {
	if (![relationName isEqual:REL_EQUIVALENT])
		return nil;
	
	return [self makeQuestionForWord:word deck:deck promptingLeft:((random() & 1) != 0)];
}

- (QuizQuestion*) makeQuestionForWord:(Word*)word deck:(Deck*)deck promptingLeft:(BOOL)promptingLeft 
{
	NSMutableArray *quizCards = [NSMutableArray array];
	for (Card *equivCard in [word cardsForRelationName:REL_EQUIVALENT]) {
		[quizCards addObject:[[QuizCard alloc] initWithCard:equivCard 
											  promptingLeft:promptingLeft
												   language:deck.language]];
	}
	
	return [[QuizQuestion alloc] initWithTitle:@"Equivalent"
									  subTitle:@""
									 quizCards:quizCards];
}

@end

@implementation BaseConjugationQuizQuestionFactory

- initWithLanguage:(id)language
{
	if ((self = [super init])) {
		m_language = language;
	}
	return self;
}

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck {
	/* Should be overridden by subclasses... */
	return OxAbstract();
}

- (NSString*) conjugatedWord:(Word*)word 
		   tensePersonPlural:(NSArray*)tense 
					language:(id)language 
					   cache:(NSMutableDictionary*)cache
{
	NSArray *key = OxArr([tense _1], [tense _2]); // person, plural
	NSArray *conj = [cache objectForKey:key];
	if (conj == nil) {
		conj = [language conjugate:word person:[[tense _1] intValue] plural:[[tense _2] intValue]];
		if (conj == nil || [conj isEmpty])
			return nil; // failed
	}
	
	return [conj objectAtIndex:[[tense _0] intValue]];
}
	
- (QuizCard*) cardForWord:(Word*)word
		tensePersonPlural:(NSArray*)tense 
				 editable:(BOOL)editable
					cache:(NSMutableDictionary*)cache
{
	NSString *strings[2] = { [word text], nil };
	NSString *kbIds[2] = { [m_language keyboardIdentifier], [m_language keyboardIdentifier] };
	BOOL editables[2] = { NO, editable };
	
	strings[1] = [self conjugatedWord:word tensePersonPlural:tense language:m_language cache:cache];
	if (strings[1] == nil) {
		// Unable to compute!
		return nil;
	}
	
	NSString *promptRelationName = [self promptRelationNameForTense:tense];

	NSArray *tenseRelationNames = [m_language relationNamesForTense:[[tense _0] intValue]
															 person:[[tense _1] intValue]
															 plural:[[tense _2] intValue]];
	NSMutableArray *relatedCardDetails = [NSMutableArray array];
	for (NSString *tenseRelationName in tenseRelationNames) {
		[relatedCardDetails addObject:[[RelatedCardDetail alloc] initWithFromString:[word text]
																	   relationName:tenseRelationName]];
	}
	
	return [[QuizCard alloc] initWithStrings:strings
								   editables:editables 
						  promptRelationName:promptRelationName
								 keyboardIds:kbIds
						  relatedCardDetails:relatedCardDetails
								 relatedRule:nil                // XXX
									language:m_language];
	
}

- (NSArray*) promptTense
{
	return OxAbstract();
}

- (NSArray*) tensesToTest:(NSArray*)promptTense
{
	return OxAbstract();
}

- (NSString*) promptRelationNameForTense:(NSArray*)tense
{
	return [[m_language tenseNames] objectAtIndex:[[tense _0] intValue]];
}

- (NSString*) subtitle:(NSArray*)promptTense
{
	return @"";
}

- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Word*)word deck:(Deck*)deck {
	NSAssert2(m_language == deck.language, @"QQF used with language %@ but expected %@", 
			  [deck.language name], [m_language name]);
	
	// Compute the relations/tenses we might want to quiz for
	NSArray *promptTense = [self promptTense];
	NSArray *testTenses = [self tensesToTest:promptTense];

	// Check if this relation is one of the ones we test conjugations for
	if (![relationName isEqual:REL_EQUIVALENT]) {
		BOOL testableRelation = NO;	
		for (NSArray *tense in testTenses) {
			NSArray *tenseRelationNames = [m_language relationNamesForTense:[[tense _0] intValue]
																	 person:[[tense _1] intValue]
																	 plural:[[tense _2] intValue]];
			OxLog(@"tenseRelationNames=%@ relationName=%@ contained=%d", 
				  tenseRelationNames, relationName,	[tenseRelationNames containsObject:relationName]);
			if ([tenseRelationNames containsObject:relationName]) { // OxExists(tenseRelationNames, isEqual:relationName)) {
				testableRelation = YES;
				break;
			}
		}
		OxLog(@"testableRelation? %d", testableRelation);
		if (!testableRelation)
			return nil;
	}

	// Cache the conjugations we have computed.
	NSMutableDictionary *conjugationsCache = [NSMutableDictionary dictionary];
	
	// Build up a collection of quizcards
	NSMutableArray *quizCards = [NSMutableArray array];
	
	// (if we have equivalents, add those)	
	for (Card *equivCard in [word cardsForRelationName:REL_EQUIVALENT]) {
		[quizCards addObject:[[QuizCard alloc] initWithCard:equivCard
											  promptingLeft:NO
												   language:m_language]];
	}
	
	// (add prompt, generally present tense)
	if (promptTense != nil) {
		QuizCard *card = [self cardForWord:word 
						 tensePersonPlural:promptTense 
								  editable:NO 
									 cache:conjugationsCache];
		if (card == nil) return nil; // failed
		[quizCards addObject:card];
	}
	
	// (now add the tenses we want them to respond in)
	for (NSArray *tense in testTenses) {
		QuizCard *card = [self cardForWord:word 
						 tensePersonPlural:tense
								  editable:YES 
									 cache:conjugationsCache];
		if (card == nil) return nil; // failed
		[quizCards addObject:card];
	}
	
	// (compute the subtitle, and return the question)
	NSString *subtitle = [self subtitle:promptTense];	
	return [[QuizQuestion alloc] initWithTitle:@"Conjugate"
									  subTitle:subtitle
									 quizCards:quizCards];
}

@end
