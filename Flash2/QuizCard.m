//
//  QuizCard.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QuizCard.h"
#import "OxNSString.h"
#import "Ox.h"
#import "OxNSMutableAttributedString.h"
#import "CardHistory.h"
#import "GrammarRuleHistory.h"
#import "History.h"
#import "Queries.h"

@implementation QuizCardSide
@synthesize expected;
@synthesize keyboardIdentifier;
@synthesize attributed;
@synthesize editable;

@end

@implementation RelatedCardDetail
@synthesize fromString = a_fromString;
@synthesize relationName = a_relationName;

- initWithFromString:(NSString*)fromString relationName:(NSString*)relationName {
	if ((self = [super init])) {
		a_fromString = fromString;
		a_relationName = relationName;
	}
	return self;
}

@end

@implementation QuizCard

- initWithStrings:(NSString*[])strings
		editables:(BOOL[])editables
promptRelationName:(NSString*)promptRelationName
	  keyboardIds:(NSString*[])kbIds
relatedCardDetails:(NSArray*)relatedCardDetails
	  relatedRule:(NSString*)relatedRule
		 language:(Language*)language
{
	if ((self = [super init])) {
		m_language = language;
		
		a_fromSide = [[QuizCardSide alloc] init];
		a_toSide = [[QuizCardSide alloc] init];
		
		QuizCardSide *sides[2] = { a_fromSide, a_toSide };
		for (int i = 0; i < 2; i++) {
			sides[i].expected = strings[i];
			sides[i].editable = editables[i];
			sides[i].attributed = [[NSAttributedString alloc] initWithString:strings[i]];
			sides[i].keyboardIdentifier = kbIds[i];
		}

		a_promptRelationName = [promptRelationName copy];
		
		a_userAnswer = @"";
		
		a_relatedCardDetails = relatedCardDetails;
		a_relatedRule = relatedRule;
		
		a_wrong = NO;
	}
	return self;
}

- initWithCard:(Card*)card
	   strings:(NSString*[])strings
 promptingLeft:(BOOL)promptLeft
	  language:(Language*)language
{
	NSString *promptRelationName = card.relationName;
	BOOL editables[2] = { promptLeft, !promptLeft };
	NSArray *relatedCardDetails = OxArr([[RelatedCardDetail alloc] initWithFromString:card.fromString
																		 relationName:card.relationName]);	
	
	NSString *kbIds[2] = { [language keyboardIdentifier], [language keyboardIdentifier] };	
	Relation *relation = [language relationNamed:card.relationName];
	if ([relation crossLanguage])
		kbIds[1] = nil;
	
	return [self initWithStrings:strings
					   editables:editables
			  promptRelationName:promptRelationName
					 keyboardIds:kbIds
			  relatedCardDetails:relatedCardDetails
					 relatedRule:nil
						language:language];
}

- initWithCard:(Card*)card
 promptingLeft:(BOOL)promptingLeft
	  language:(Language*)language
{
	NSString *strings[2] = { card.fromString, card.toString };
	return [self initWithCard:card strings:strings promptingLeft:promptingLeft language:language];
}

@synthesize fromSide = a_fromSide;
@synthesize toSide = a_toSide;
@synthesize promptRelationName = a_promptRelationName;
@synthesize userAnswer = a_userAnswer;

@synthesize relatedCardDetails = a_relatedCardDetails;
@synthesize relatedRule = a_relatedRule;

@synthesize wrong = a_wrong;

NSAttributedString *checkEntry(NSString *expected, NSString *actual, BOOL *wrong) 
{
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
	
	NSString *expectedMinusParens = [[expected stringByPurgingParentheticalText] normalizeWhitespace];
	NSString *actualMinusParens = [[actual stringByPurgingParentheticalText] normalizeWhitespace];
	
	if (![actualMinusParens isEqualToStringIgnoringCase:expectedMinusParens]) {
		[result appendString:expected withColor:[NSColor redColor]];
		[result appendString:@" "];
		[result appendString:actual withAttributes:OxDict(OxInt(1) FOR NSStrikethroughStyleAttributeName)];
		*wrong = YES;
	} else 
		[result appendString:expected];

	return result;
}

- (void) checkSide:(QuizCardSide*)side wrong:(BOOL*)wrong
{
	if (side.editable) {
		side.attributed = checkEntry(side.expected, self.userAnswer, wrong);
		side.editable = NO;
	} 
}

- (void) check 
{
	BOOL wrong = NO;

	// Compare the user-provided answer against what we expected:
	[self checkSide:self.fromSide wrong:&wrong];
	[self checkSide:self.toSide wrong:&wrong];
	
	self.wrong = wrong;
}

void initializeHistory(History *previousHistory, History *currentHistory, int level) {
	int nextDuration; // in seconds
	if (previousHistory != nil) {
		previousHistory.mostRecent = OxNO;
		nextDuration = [previousHistory.duration intValue];
		if (level == TOO_EASY)
			nextDuration *= 2;
		else
			nextDuration /= 2;
	} else {
		const int day = 60 * 60 * 24;
		nextDuration = level * day;
	}
	
	currentHistory.mostRecent = OxYES;
	currentHistory.duration = OxInt(nextDuration);
	currentHistory.howCorrect = OxInt(level);
	currentHistory.expirationDate = [NSDate dateWithTimeIntervalSinceNow:nextDuration];
}

- (NSArray*) relatedCardsInManagedObjectContext:(NSManagedObjectContext*)mctx
{
	NSMutableArray *relatedCards = [NSMutableArray array];
	for (RelatedCardDetail *detail in self.relatedCardDetails) {
		[relatedCards addObjectsFromArray:[mctx cardsWithFromString:detail.fromString 
													   relationName:detail.relationName 
														   language:m_language]];
	}
	return relatedCards;
}

- (void) mark:(int)level managedObjectContext:(NSManagedObjectContext*)mctx
{	
	for (Card *card in [self relatedCardsInManagedObjectContext:mctx]) {
		History *oldMrh = [mctx mostRecentHistoryForCard:card];
		CardHistory *newMrh = [NSEntityDescription insertNewObjectForEntityForName:E_CARD_HISTORY
															 inManagedObjectContext:mctx];
		newMrh.card = card;
		initializeHistory(oldMrh, newMrh, level);
	}
	
	if (self.relatedRule) {
		History *oldMrh = [mctx mostRecentHistoryForGrammarRuleNamed:self.relatedRule language:m_language];
		GrammarRuleHistory *newMrh = [NSEntityDescription insertNewObjectForEntityForName:E_GRAMMAR_RULE_HISTORY
																   inManagedObjectContext:mctx];
		newMrh.grammarRuleName = self.relatedRule;
		newMrh.languageVersion = [mctx languageVersionForLanguage:m_language];
		initializeHistory(oldMrh, newMrh, level);
	}
}

- (NSString*) description 
{
	return OxFmt(@"%@ -%@-> %@", self.fromSide.expected, self.promptRelationName, self.toSide.expected);
}

@end
