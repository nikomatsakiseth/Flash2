//
//  BaseLanguage.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Ox.h"
#import "BaseLanguage.h"
#import "OxNSArray.h"
#import "OxDebug.h"
#import "Model.h"

@implementation Relation

@synthesize name, crossLanguage, cardKind;

- initWithName:(NSString*)aName 
 crossLanguage:(BOOL)aCrossLanguage
	  cardKind:(NSString*)aCardKind
{
	if ((self = [super init])) {
		name = [aName copy];
		crossLanguage = aCrossLanguage;
		cardKind = [aCardKind copy];
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[cardKind release];
	[super dealloc];
}

@end

@implementation BaseLanguage

- initFromPlistNamed:(NSString*)plistName
			inBundle:(NSBundle*)bundle
{
	if((self = [super init])) {
		plist = [[NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:plistName
																			 ofType:@"plist"]] retain];
		if(plist == nil) {
			[self release];
			return nil;
		}
		
		name = [[plist objectForKey:@"name"] copy];
		identifier = [[plist objectForKey:@"identifier"] copy];
		keyboardIdentifier = [[plist objectForKey:@"keyboardIdentifier"] copy];
		relations = [[NSMutableDictionary alloc] init];
		cardKinds = [[NSMutableArray alloc] init];
		grammarRules = [[NSMutableArray alloc] init];
		languageVersion = [[plist objectForKey:@"languageVersion"] intValue];
		
		// Expand relations and create Relation objects:
		for (NSDictionary *relationData in [plist objectForKey:@"relations"]) {
			Relation *r = [[[Relation alloc] initWithName:[relationData objectForKey:@"name"]
											crossLanguage:[[relationData objectForKey:@"crossLanguage"] boolValue]
												 cardKind:[relationData objectForKey:@"cardKind"]] autorelease];
			[relations setObject:r forKey:r.name];
		}
		
		// Create card kinds and grammar rules from plist:
		[cardKinds addObjectsFromArray:[[plist objectForKey:@"cardKinds"] expandLanguageDefn]];
		[grammarRules addObjectsFromArray:[[plist objectForKey:@"grammarRules"] expandLanguageDefn]];
	}
	return self;
}

- (NSArray*) conjugate:(Card*)word person:(int)person plural:(BOOL)plural
{
	return nil; // should be overridden most likely!
}

- (NSArray*)grammarRules
{
	return grammarRules;
}

- (BOOL)isCrossLanguageRelation:(NSString *)relationName
{
	Relation *relation = [relations objectForKey:relationName];
	return relation.crossLanguage;
}

- (NSArray*)allRelationNames
{
	return [relations allKeys];
}

// By default:
//    Relations apply if their card kind is a prefix of 'cardKind'.
//    Subtypes could override this method to adjust that rule.
- (NSArray*)relationNamesForCardKind:(NSString *)cardKind
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[relations count]];
	for(Relation *relation in [relations allValues]) {
		if([cardKind hasPrefix:relation.cardKind])
			[result addObject:relation.name];
	}
	return result;
}

- (NSString*)guessKindOfText:(NSString *)aText
{
	OxAbstract(); // totally language dependent!
	return @"Other";
}

- (NSArray*)cardKinds
{
	return cardKinds;
}

- (NSString*)keyboardIdentifier
{
	return keyboardIdentifier;
}

- (NSString*)identifier
{
	return identifier;
}

- (NSString*)name
{
	return name;
}

- (int)languageVersion
{
	return languageVersion;
}

- (NSDictionary*)upgradeData:(NSDictionary*)data
		 fromLanguageVersion:(int)version
{
	OxAbstract();
	return nil;
}

- (NSString*)protocolVersion
{
	return FLASH2_PROTOCOL_V1;
}

- (NSString*)autoPropertyForCard:(Card *)aCard relationName:(NSString *)aRelationName
{
	return nil;
}

@end

#if 0
@implementation EquivalentQuizQuestionFactory

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck {
	return nil; // EQUIVALENT factory only works off of cards.
}

- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Card*)word deck:(Deck*)deck {
	if (![relationName isEqual:REL_EQUIVALENT])
		return nil;
	
	return [self makeQuestionForWord:word deck:deck promptingLeft:((random() & 1) != 0)];
}

- (QuizQuestion*) makeQuestionForWord:(Card*)word deck:(Deck*)deck promptingLeft:(BOOL)promptingLeft 
{
	NSMutableArray *quizCards = [NSMutableArray array];
	for (Property *equivCard in [word relatedProperties:REL_EQUIVALENT]) {
		[quizCards addObject:[[QuizCard alloc] initWithCard:equivCard 
											  promptingLeft:promptingLeft
												   language:deck.language]];
	}
	
	return [[QuizQuestion alloc] initWithTitle:@"Equivalent"
									  subTitle:@""
									 quizCards:quizCards];
	return nil;
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

- (NSString*) conjugatedWord:(Card*)word 
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
	
- (QuizCard*) cardForWord:(Card*)word
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

- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Card*)word deck:(Deck*)deck {
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
#endif


#pragma mark -
#pragma mark Plist Expansion Rules

// See header file

@implementation NSString (LanguagePlistExpansion)
- (NSArray*) expandLanguageDefn {
	return OxArr(self);
}
@end

@implementation NSDictionary (LanguagePlistExpansion)
void expand(NSMutableArray *base, NSMutableArray *into, NSArray *remainingEntries) {
	if ([remainingEntries isEmpty]) 
		[into addObject:[base componentsJoinedByString:@"-"]];
	else {
		NSArray *entry = [remainingEntries objectAtIndex:0];
		remainingEntries = [remainingEntries sliceFrom:1];
		for (NSString *str in entry) {
			int index = [base count];
			[base insertObject:str atIndex:index];
			expand(base, into, remainingEntries);
			[base removeObjectAtIndex:index];
		}
	}
}

- (NSArray*) expandLanguageDefn {
	NSMutableArray *expandedValues = [NSMutableArray array];
	for (NSString *prefix in [[self allKeys] sortedArrayUsingSelector:@selector(compare:)])
		[expandedValues addObject:[[self objectForKey:prefix] expandLanguageDefn]];
	
	NSMutableArray *result = [NSMutableArray array];	
	expand([NSMutableArray array], result, expandedValues);	
	return result;
}
@end

@implementation NSArray (LanguagePlistExpansion)
- (NSArray*) expandLanguageDefn {
	NSMutableArray *result = [NSMutableArray array];
	for(id entry in self)
		[result addObjectsFromArray:[entry expandLanguageDefn]];
	return result;
}
@end
