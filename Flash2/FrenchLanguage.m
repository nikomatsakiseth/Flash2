// -*- coding: utf-8; -*-
//
//  FrenchLanguage.m
//  Flash2
//
//  Created by Nicholas Matsakis on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FrenchLanguage.h"
#import "OxNSArray.h"
#import "OxNSString.h"
#import "OxHom.h"
#import "Ox.h"
#import "Model.h"

#define REL_PAST_PART @"Past Participle" // must match .plist
#define REL_HELPER_VERB @"Helper Verb" // must match .plist

static BOOL startsWithVowel(NSString *string) {
	NSArray *vowels = OxArr(@"a", @"e", @"i", @"o", @"u", 
							@"ha", @"he", @"hi", @"ho", @"hu"); // Technically, h does not ALWAYS qualify.
	return OxIExists(string, hasPrefix:OxForEach(vowels) options:NSDiacriticInsensitiveSearch);
}

// Implement translations like "je ai" => "j'ai" or "je me assois" => "je m'assois"
static NSString *combineLosingVowel(NSString *pre, NSString *txt) {
	if ([pre hasSuffix:@"e"] && startsWithVowel(txt)) {
		return OxFmt(@"%@'%@", [pre sliceTo:-1], txt);
	}
	return OxFmt(@"%@ %@", pre, txt);
}

#pragma mark -
#pragma mark Conjugation
#pragma mark -

// Must match .plist file!
typedef enum {
	PRESENT,
	PASSE_COMP,
	IMPARFAIT,
	MAX_TENSE
} Tense;

#if 0

@interface FrenchVerb : WordCategory {
	BOOL m_reflexive;
	NSString *m_stem;
}

+ (FrenchVerb*) categorize:(Card*)word language:(FrenchLanguage*)lang;

- initWithCard:(Card*)word language:(FrenchLanguage*)lang;

- (NSArray*) conjugateInTense:(Tense)tense;

- (NSArray*) conjugateInPresentTense;
- (NSString*) stem;
- (NSArray*) presentTenseEndings;

- (NSArray*) conjugateInImparfait;

- (NSString*) pastParticiple;

@end
	
@interface FrenchVerbEr : FrenchVerb {
}

+ (NSString*) suffix;
- (NSArray*) presentTenseEndings;
- (NSString*) pastParticiple;

@end

@interface FrenchVerbIr : FrenchVerb {
}

+ (NSString*) suffix;
- (NSArray*) presentTenseEndings;
- (NSString*) pastParticiple;

@end

@interface FrenchVerbRe : FrenchVerb {
}

+ (NSString*) suffix;
- (NSArray*) presentTenseEndings;
- (NSString*) pastParticiple;

@end

@implementation FrenchVerb

+ (FrenchVerb*) categorize:(Card*)word language:(FrenchLanguage*)lang
{
	NSString *text = [word text];
	Class kinds[] = { 
		[FrenchVerbEr class], [FrenchVerbRe class], [FrenchVerbIr class], nil
	};
	
	text = [[[word text] stringByPurgingParentheticalText] strip];
	for (int i = 0; kinds[i]; i++) {
		if ([text hasSuffix:[kinds[i] suffix]])
			return [[kinds[i] alloc] initWithCard:word language:lang];
	}

	return nil;
}

+ (NSString*) suffix
{
	return OxAbstract();
}

- initWithCard:(Card*)word language:(FrenchLanguage*)lang
{
	if ((self = [super initWithCard:word language:lang])) {
		NSString *text = [m_word text];
		NSString *suffix = [[self class] suffix];
		
		if ([text hasPrefix:@"se "]) {
			m_reflexive = YES;
			text = [text sliceFrom:3];
		} else if ([text hasPrefix:@"s'"]) {
			m_reflexive = YES;
			text = [text sliceFrom:2];
		}
		
		if ([text hasSuffix:suffix])
			m_stem = [text sliceTo:-[suffix length]];
		else
			m_stem = text;
	}
	return self;
}

- (NSArray*) presentTenseEndings
{
	return OxAbstract();
}

- (NSString*) pastParticiple
{
	return OxAbstract();
}

- (NSString*) stem
{
	return m_stem;
}

- (NSArray*) override:(NSArray*)programmatic withRelationNames:(NSArray*)relationNames
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:programmatic];
	int index = 0;
	for (NSString *relationName in relationNames) {
		if ([m_word hasRelatedText:relationName]) {
			NSString *txt = [m_word relatedText:relationName];
			[result replaceObjectAtIndex:index withObject:txt];
		}
		index++;
	}
	return result;
}

- (NSArray*) conjugateHelper:(NSString*)helper
{
	if ([helper isEqualToStringIgnoringCase:Utf8("être")] || [helper isEqualToStringIgnoringCase:@"etre"])
		return OxArr(@"suis", @"est", @"et", @"sommes", Utf8("êtes"), @"sont");
	return OxArr(@"ai", @"as", @"a", @"avons", @"avez", @"ont");
}

- (NSArray*) conjugateInTense:(Tense)tense
{
	NSArray *programmatic;
	NSArray *result;
	switch(tense) {
		case PRESENT: programmatic = [self conjugateInPresentTense]; goto full;
		case IMPARFAIT: programmatic = [self conjugateInPresentTense]; goto full;
		full: {
			result = [self override:programmatic withRelationNames:[m_lang relationNamesForTense:PRESENT]];
			break;
		}
			
		case PASSE_COMP: {
			NSString *pastParticiple = [m_word relatedText:REL_PAST_PART ifNone:[self pastParticiple]];
			NSString *helperVerb = [m_word relatedText:REL_HELPER_VERB ifNone:@"avoir"];
			if (m_reflexive) 
				helperVerb = @"être";
			NSArray *helperConjugations = [self conjugateHelper:helperVerb];
			result = OxMap(helperConjugations, stringByAppendingString:OxFmt(@" %@", pastParticiple));
			break;
		}
			
		default: {
			result = nil;
			break;
		}
	}
	
	if (result && m_reflexive) {
		NSArray *pronouns = OxArr(@"me", @"te", @"se", @"nous", @"vous", @"se");
		NSMutableArray *withPronouns = [NSMutableArray array];
		for (NSArray *pair in [pronouns zippedArrayWith:result]) 
			[withPronouns addObject:combineLosingVowel([pair _0], [pair _1])];
		return withPronouns;
	}
	
	return result;
}

- (NSArray*) conjugateInPresentTense
{
	// Programmatically generate present tense:
	NSString *stem = [self stem];
	NSArray *endings = [self presentTenseEndings];
	return OxIMap(stem, stringByAppendingString:OxForEach(endings));
}

- (NSArray*) conjugateInImparfait
{
	NSArray *presentTense = [self conjugateInPresentTense];
	NSString *nous = [presentTense objectAtIndex:4]; // 1st person, plural	
	NSString *stem = [nous sliceTo:-3]; // chop off "ons"
	NSArray *endings = OxArr(@"ais", @"ais", @"ait", @"ions", @"iez", @"aient");
	return OxIMap(stem, stringByAppendingString:OxForEach(endings));
}

@end

@implementation FrenchVerbEr

+ (NSString*) suffix
{
	return @"er";
}

- (NSArray*) presentTenseEndings
{
	return OxArr(@"e", @"es", @"e", @"ons", @"ez", @"ent");
}

- (NSString*) pastParticiple
{
	return [[self stem] stringByAppendingString:Utf8("é")];
}

@end

@implementation FrenchVerbRe

+ (NSString*) suffix
{
	return @"re";
}

- (NSArray*) presentTenseEndings
{
	return OxArr(@"s", @"s", @"", @"ons", @"ez", @"ent");
}

- (NSString*) pastParticiple
{
	return [[self stem] stringByAppendingString:Utf8("u")];
}


@end

@implementation FrenchVerbIr

+ (NSString*) suffix
{
	return @"ir";
}

- (NSArray*) presentTenseEndings
{
	return OxArr(@"is", @"is", @"it", @"issons", @"issez", @"issent");
}

- (NSString*) pastParticiple
{
	return [[self stem] stringByAppendingString:Utf8("i")];
}

@end

@interface FrenchNoun : WordCategory {
	NSString *m_article;
}

+ (FrenchNoun*) categorize:(Card*)word language:(FrenchLanguage*)lang;

- initWithCard:(Card*)word article:(NSString*)article;

- (NSString*) withoutArticle;
- (NSString*) article;

@end

@implementation FrenchNoun

+ (FrenchNoun*) categorize:(Card*)word language:(FrenchLanguage*)lang
{
	NSString *text = [word text];
	NSArray *articles = OxArr(@"le", @"la");
	
	for (NSString *article in articles)
		if ([text hasPrefix:OxFmt(@"%@ ", article)])
			return [[FrenchNoun alloc] initWithCard:word article:article];			
	return nil;
}

- initWithCard:(Card*)word article:(NSString*)article
{
	if ((self = [super init])) {
		m_word = word;
		m_article = article;
	}
	return self;
}

- (NSString*) withoutArticle
{
	NSString *text = [m_word text];
	return [text substringFromIndex:[m_article length]+1];
}

- (NSString*) article
{
	return m_article;
}

@end
#endif

#pragma mark -
#pragma mark Quiz Question Factories
#pragma mark -

#if 0
@interface FrenchConjugationQuizQuestionFactory : BaseConjugationQuizQuestionFactory {
}
@end

@implementation FrenchConjugationQuizQuestionFactory

// in French, for now we always test same person: je

- (NSArray*) promptTense
{
	return nil; // no prompt in French, because we always test same set of persons
}

- (NSArray*) tensesToTest:(NSArray*)promptTense
{
	return OxArr(OxArr(OxInt(PRESENT), OxInt(0), OxInt(0)),       // present (je)
				 OxArr(OxInt(PRESENT), OxInt(0), OxInt(1)),       // present (nous)
				 //OxArr(OxInt(IMPARFAIT), OxInt(0), OxInt(0)),     // imparfait
				 OxArr(OxInt(PASSE_COMP), OxInt(0), OxInt(0)));   // passe comp.
}

- (NSString*) promptRelationNameForTense:(NSArray*)tense
{
	int tenseIdx = [[tense _0] intValue];
	int person = [[tense _1] intValue];
	int plural = [[tense _2] intValue];
	
	NSString *tenseName = [[m_language tenseNames] objectAtIndex:tenseIdx];
	NSString *article = [[m_language articles] objectAtIndex:person+plural*3];
	return OxFmt(@"%@ (%@)", tenseName, article);
}

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck
{
	return nil;
}

@end

@interface FrenchEquivalentQuizQuestionFactory : EquivalentQuizQuestionFactory {
	id m_language;
}
- initWithLanguage:(id)language;
@end

@implementation FrenchEquivalentQuizQuestionFactory


- initWithLanguage:(id)language
{
	if ((self = [super init])) {
		m_language = language;
	}
	return self;
}

- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Card*)word deck:(Deck*)deck {
	if (![relationName isEqual:REL_EQUIVALENT])
		return nil;
	
	BOOL promptingLeft = (random() & 1);
	
	// If we are prompting with the English text, and this is a noun,
	// hide the article and make user give it explicitly.
	if (!promptingLeft) {
		FrenchNoun *noun = [FrenchNoun categorize:word language:m_language];
		if (noun) {
			NSArray *equivCards = [word cardsForRelationName:REL_EQUIVALENT];
			NSMutableArray *quizCards = [NSMutableArray array];
			NSString *strings[2] = { [noun withoutArticle], nil };
			
			BOOL editables[2] = { NO, YES };
			strings[1] = [noun article];
			NSString *kbIds[2] = { [m_language keyboardIdentifier], [m_language keyboardIdentifier] };
			[quizCards addObject:[[QuizCard alloc] initWithStrings:strings
														 editables:editables 
												promptRelationName:@"Article"
													   keyboardIds:kbIds 
												relatedCardDetails:equivCards
													   relatedRule:nil 
														  language:m_language]];
			
			for (Card *equivCard in equivCards) {
				strings[1] = equivCard.toString;
				[quizCards addObject:[[QuizCard alloc] initWithCard:equivCard 
															strings:strings
													  promptingLeft:NO
														   language:m_language]];
			}			
			
			return [[QuizQuestion alloc] initWithTitle:@"Equivalent and Article"
											  subTitle:@""
											 quizCards:quizCards];
		}
	}

	// Otherwise, just fallback to normal prompts.
	return [self makeQuestionForWord:word deck:deck promptingLeft:promptingLeft];
}

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck
{
	return nil;
}

@end
#endif

#pragma mark -
#pragma mark Language Class
#pragma mark -

@implementation FrenchLanguage

- (Relation*) relationNamed:(NSString*)relName
{
	return [[Relation alloc] initWithName:relName crossLanguage:NO cardKind:@"Verb"];
}

- (void)addRelationsFromArray:(NSArray*)rels
{
	for(Relation *rel in rels)
		[relations setObject:rel forKey:rel.name];
}

- init
{
	if ((self = [super initFromPlistNamed:@"FrenchLanguage"
								 inBundle:[NSBundle mainBundle]]))
	{
		[self addRelationsFromArray:OxIMap(self, relationNamed:OxForEach([self relationNamesForTense:PRESENT]))];
		[self addRelationsFromArray:OxIMap(self, relationNamed:OxForEach([self relationNamesForTense:IMPARFAIT]))];
	}
	return self;
}

- quizQuestionFactories
{
	return nil;
#if 0
	return OxArr([[FrenchEquivalentQuizQuestionFactory alloc] initWithLanguage:self],
				 [[FrenchConjugationQuizQuestionFactory alloc] initWithLanguage:self]);
#endif
}

- (NSArray*) articles 
{
	return OxArr(@"je", @"tu", @"il", @"nous", @"vous", @"ils");
}
			
- (NSArray*) relationNamesForTense:(int)tense
{
	NSString *tenseName = [[self tenseNames] objectAtIndex:tense];
	NSMutableArray *result = [NSMutableArray array];
	for (NSString *article in [self articles])
		[result addObject:OxFmt(@"%@ (%@)", tenseName, article)];
	return result;
}

- (NSArray*) relationNamesForTense:(int)tense person:(int)person plural:(int)plural
{
	if (tense == PASSE_COMP) {
		return OxArr(REL_PAST_PART, REL_HELPER_VERB);
	} else {
		int index = person;
		if (plural) index += 3;
		NSString *tenseName = [[self tenseNames] objectAtIndex:tense];
		NSString *article = [[self articles] objectAtIndex:index];
		return OxArr(OxFmt(@"%@ (%@)", tenseName, article));
	}
}
			
- (NSArray*) tenseNames 
{
	return [[[plist objectForKey:@"grammarRules"] _0] objectForKey:@"2 Tense"];
}

#if 0
- (NSArray*) conjugate:(Card*)word person:(int)person plural:(BOOL)plural
{
	int index = person;
	if (plural) index += 3;
	
	FrenchVerb *verb = [FrenchVerb categorize:word language:self];
	if (verb == nil)
		return nil;
	
	NSMutableArray *result = [NSMutableArray array];
	for (int tense = 0; tense < MAX_TENSE; tense++) {
		NSArray *conjugations = [verb conjugateInTense:tense];
		[result addObject:[conjugations objectAtIndex:index]];
	}
	
	// add article:
	NSString *article = [[self articles] objectAtIndex:index];
	for (int tense = 0; tense < MAX_TENSE; tense++) {
		NSString *conjugation = [result objectAtIndex:tense];
		NSString *withArticle = combineLosingVowel(article, conjugation);
		[result replaceObjectAtIndex:tense withObject:withArticle];
	}
						 	
	return result;
}
#endif

@end
