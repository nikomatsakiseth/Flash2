// -*- coding: utf-8; -*-
//
//  GreekLanguage.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
// 

#import "GreekLanguage.h"
#import "BaseLanguage.h"
#import "GreekLanguageController.h"
#import "OxNSString.h"
#import "Ox.h"
#import "Card.h"
#import "Deck.h"
#import "Word.h"
#import "QuizQuestion.h"
#import "QuizCard.h"
#import "OxNSArray.h"
#import "Ox.h"

#pragma mark -
#pragma mark Greek Alphabet Literals
#pragma mark -

#define Gr(X)      Utf8(X)
#define GrArr(...) Utf8Arr(__VA_ARGS__)

static NSString *AdjustStress(NSString *self, BOOL add) {
	NSArray *pairs = GrArr("ά", "α", "έ", "ε", "ί", "ι", "ό", "ο", "ύ", "υ", "ώ", "ω");
	self = [self decomposedStringWithCanonicalMapping];
	for (int i = 0; i < [pairs count]; i += 2) {
		NSString *withAccent = [pairs objectAtIndex:i];
		NSString *withoutAccent = [pairs objectAtIndex:i+1];
		if (add)
			self = [self stringByReplacingOccurrencesOfString:withoutAccent withString:withAccent];
		else 
			self = [self stringByReplacingOccurrencesOfString:withAccent withString:withoutAccent];
	}
	return self;
}

#pragma mark -
#pragma mark Syllabization and Accents
#pragma mark -

typedef enum { CONSONANT, VOWEL, OTHER, EOS } TokenKind;
@interface GreekTokenizer : NSObject {
	NSCharacterSet *m_consonants, *m_vowels;
	NSArray *m_dipthongs; //, *m_nondipthongs;
	
	// Current token:
	TokenKind a_kind;
	NSString *a_token;

	// Remaining string:
	NSString *m_remaining;
}
- initWithString:(NSString*)string;
@property (readwrite) TokenKind kind;
@property (retain) NSString *token;
- (void) consumeToken;
- (NSString*) remainingString;
@end

@implementation GreekTokenizer
- initWithString:(NSString*)string {
	if ((self = [super init])) {
		NSString *consonantString = Gr("βγδζθκλμνξπρστφχψ");
		NSString *vowelString = Gr("αεηιουω");
		m_consonants = [NSCharacterSet characterSetWithCharactersInString:consonantString];
		m_vowels = [NSCharacterSet characterSetWithCharactersInString:vowelString];
		m_dipthongs = GrArr("αι", "αυ", "ει", "οι", "ου", "υι",
							"αί", "αύ", "εί", "οί", "ού", "υί");
		m_remaining = [string decomposedStringWithCanonicalMapping];
		
		self.kind = OTHER;
		self.token = @"";
		
		[self consumeToken];
	}
	return self;
}

@synthesize kind = a_kind;
@synthesize token = a_token;

- (NSString*) remainingString
{
	return m_remaining;
}

- (void) consumeToken
{
	NSRange tokenRange = NSMakeRange(0, 0);
	self.kind = OTHER;
	
	// check for empty string
	if ([m_remaining isEqual:@""])
		self.kind = EOS;
	
	// check for dipthong:
	if (self.kind == OTHER && [m_remaining length] >= 2) {
		// extract first 2 characters including accents etc
		tokenRange = [m_remaining rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 2)];
		NSString *potentialDipthong = [m_remaining substringWithRange:tokenRange];
		if ([m_dipthongs containsObject:potentialDipthong])
			self.kind = VOWEL;
	}

	// check for plain vowel or consonant:
	if (self.kind == OTHER) {
		unichar chr = [m_remaining characterAtIndex:0];
		tokenRange = NSMakeRange(0, 1);
		if ([m_consonants characterIsMember:chr])
			self.kind = CONSONANT;
		else if ([m_vowels characterIsMember:chr])
			self.kind = VOWEL;
	}
	
	// otherwise it's just "other"
	if (self.kind == OTHER)
		tokenRange = NSMakeRange(0, 1);
		
	// extend token range to include any accents
	tokenRange = [m_remaining rangeOfComposedCharacterSequencesForRange:tokenRange];
	NSAssert(tokenRange.location == 0, @"Range starting from non-zero location");
	self.token = [m_remaining substringWithRange:tokenRange];
	m_remaining = [m_remaining substringFromIndex:tokenRange.length];
}

@end

@implementation NSString (GreekLanguage)

- (NSArray*) greekSyllables {
	// Syllables contain a single vowel sound.  That vowel sound may be preceded or followed
	// by certain consonants.  Basically, we syllabize according to the following regex:
	// 
	// C* V
	
	// Combinations of two letters that may begin a Greek word:
	NSArray *clusters = GrArr( // from Concise Modern Greek Grammar by Manols Triandaphyllidis, combined w/ dict
							 "χτ", "κτ", "γκ", "χθ", "φτ", "πτ", "φθ", "στ", 
							 "σθ", "σκ", "σχ", "μπ", "μβ", 
							 "ντ", "νδ", "βμ", "φχ", "φσ", 
							 "χν", "γχ"
							 );
	
	// special case
	if ([self isEqual:Gr("μια")])
		return OxArr(self); 
	
	NSMutableArray *syllables = [NSMutableArray array];
	GreekTokenizer *gt = [[GreekTokenizer alloc] initWithString:self];

	NSString *carryOver = @"";
	while (gt.kind != EOS) {		
		NSMutableString *syllable = [NSMutableString stringWithString:carryOver];
		carryOver = @"";
		
		// Group all continuous OTHER tokens into a "syllable"		
		if (gt.kind == OTHER) {
			NSAssert([syllable isEqual:@""], @"Leftover consonants, but non-vowel");
			while (gt.kind == OTHER) {
				[syllable appendString:gt.token];
				[gt consumeToken];
			}
			[syllables addObject:syllable];
			continue;
		}
		
		while (gt.kind == CONSONANT) {
			[syllable appendString:gt.token];
			[gt consumeToken];
		}
		
		if (gt.kind == VOWEL) {
			[syllable appendString:gt.token];
			[gt consumeToken];
			
			// accumulate any consonants that follow
			NSMutableString *consonants = [NSMutableString string];
			while (gt.kind == CONSONANT) {
				[consonants appendString:gt.token];
				[gt consumeToken];
			}
			
			if (gt.kind == VOWEL) {
				// determine how to parcel out consonants between this 
				// syllable and the next
				if ([consonants length] <= 1) {
					// Rule 42.1: A consonant between two vowels forms a syllable with
					// the second vowel.
					carryOver = consonants;
				} else if ([consonants length] >= 2) {
					// Rule 42.2: Two consonants form with second vowel if a Greek
					// word can start with the two consonants.
					// Rule 42.3: Three consonants form with second vowel if a Greek
					// word can start with at least the first two consonants
					NSString *firstTwo = ([consonants length] == 2
											? consonants
											: [consonants substringToIndex:3]);
					if ([clusters containsObject:firstTwo]) {
						carryOver = consonants;
					} else {						
						[syllable appendString:[consonants substringToIndex:1]];
						carryOver = [consonants substringFromIndex:1];
					} 
				} 
			} else {
				// otherwise, terminating consonants accumulate with prior vowel
				[syllable appendString:consonants];
			}
		} 

		[syllables addObject:[syllable copy]];
	}
	
	NSAssert([carryOver isEqual:@""], @"Carryover consonants at termination");
	
	return syllables;
}

- (NSString*) greekRemoveStress
{	
	return AdjustStress(self, NO);
}

- (NSString*) greekAddStress
{	
	GreekTokenizer *gt = [[GreekTokenizer alloc] initWithString:self];
	NSMutableString *result = [NSMutableString string];
	while (gt.kind != EOS) {
		if (gt.kind == VOWEL) {
			NSString *finalVowel = [gt.token sliceFrom:-1];
			NSString *accentedFinalVowel = AdjustStress(finalVowel, YES);
			[result appendString:[gt.token sliceTo:-1]];
			[result appendString:accentedFinalVowel];
			[result appendString:[gt remainingString]];
			break;
		} else {
			[result appendString:gt.token];
			[gt consumeToken];
		}
	}
	return result;
}

// Returns the number of sylables from the end
// where stress is located (1 == last syllable)
- (int) greekFindStress
{
	NSString *canonSelf = [self decomposedStringWithCanonicalMapping];
	NSArray *syllables = [canonSelf greekSyllables];
	int counter = 0;
	for (NSString *syllable in syllables) {
		if (![[syllable greekRemoveStress] isEqual:syllable])
			return [syllables count] - counter;
	}
	
	// No accent...
	return 0;
}

- (NSString*) greekStringWithShiftedStress:(int)fromEnd // counted from end, 1 == last syllable
{
	NSMutableArray *syllables = [NSMutableArray arrayWithArray:[[self greekRemoveStress] greekSyllables]];
	int syllableIndex = [syllables count] - fromEnd;

	// saturate so we always put the stress somewhere
	if (syllableIndex < 0)
		syllableIndex = 0;
	else if (syllableIndex >= [syllables count])
		syllableIndex = [syllables count] - 1;

	NSString *syllable = [syllables objectAtIndex:syllableIndex];
	[syllables replaceObjectAtIndex:syllableIndex withObject:[syllable greekAddStress]];
	
	return [syllables componentsJoinedByString:@""];
}

@end

NSArray *changeEnding(NSArray *words, NSString *oldEnding, NSString *newEnding) {
	// Change from 1st person singular to the appropriate ending
	for (int i = 0; i < [words count]; i++) {
		NSString *word = [words objectAtIndex:i];					
		if ([GrArr("θα", "να") containsObject:word])
			continue; // find first inflected word
		
		if ([word hasSuffix:oldEnding]) {
			NSString *endingless = [word sliceTo:-[oldEnding length]];
			NSString *newWord = OxFmt(@"%@%@", endingless, newEnding);
			return [words arrayByReplacingObjectAtIndex:i withObject:newWord];						
		}
		break;
	}
	
	return words;
}

#pragma mark -
#pragma mark Word Transformation
#pragma mark -

// These HAVE to correspond one to one with
// what is in the plist file under grammarRules > Ρημα- > Item 3!
// See [GreekLanguage tenseNames] below.
typedef enum {
	ENESTWTAS,        // γράφω         X
	SYN_MELLONTAS,    // θα γράφω      X
	SYN_YPOTAKTIKH,   // να γράφω      X
	PARATATIKOS,      // έγραφα        X
	DYNHTIKH,         // θα έγραφα      X
	SYN_PROSTAKTIKH,  // γράφε         X?
	METOXH,           // γράφοντας     
	AORISTOS,         // έγραψε       X
	MELLONVTAS,       // θα γράψω    X
	YPOTAKTIKH,       // να γράψω    X
	PROSTAKTIKH,      // γράψε         X?
	PARAKEIMENOS,     // έχω γράψει     X
	YPERSYNTELIKOS,   // είχα γράψει     X
	SYNT_MELLONTAS,   // θα έχω γράψει  X
	MAX_TENSE
} Tense;

struct Conjugation {
	int person; // 1, 2, 3
	BOOL plural;	
};

#pragma mark Verbs

@interface GreekVerb : WordCategory {
}

+ (GreekVerb*) categorize:(Word*)word language:(GreekLanguage*)lang;

+ (NSString*) suffix;

+ (NSString*) explicitTag;

- (NSArray*) conjugateInTense:(Tense)tense;
- (NSArray*) programmaticallyConjugateInTense:(Tense)tense;

@end

@interface GreekVerbActive : GreekVerb {} @end 
@interface GreekVerbActiveA : GreekVerbActive {} @end   // -ω
@interface GreekVerbActiveB : GreekVerbActive {} @end
@interface GreekVerbActiveB1 : GreekVerbActiveB {} @end  // -άω
@interface GreekVerbActiveB2 : GreekVerbActiveB {} @end  // -ώ

/*
@interface GreekVerbPassive : GreekVerb {} @end
@interface GreekVerbPassiveA : GreekVerbPassive {} @end   // -ομαι
@interface GreekVerbPassiveB : GreekVerbPassive {} @end
@interface GreekVerbPassiveB1 : GreekVerbPassiveB {} @end  // -ούμαι
@interface GreekVerbPassiveB2 : GreekVerbPassiveB {} @end  // -ιέμαι
*/

NSString *firstPersonSingular(NSArray *endings) {
	return [[endings objectAtIndex:0] objectAtIndex:0];
}
 
@implementation GreekVerb

+ (GreekVerb*) categorize:(Word*)word language:(GreekLanguage*)lang
{
	NSString *text = [word text];
	Class kinds[] = { 
		[GreekVerbActiveA class], [GreekVerbActiveB1 class], [GreekVerbActiveB2 class],
		//[GreekVerbPassiveA class], [GreekVerbPassiveB1 class], [GreekVerbPassiveB2 class],
		nil
	};
#   define select(i) [[kinds[i] alloc] initWithWord:word language:lang]

	// Check for an explicit tag:
	for (int i = 0; kinds[i]; i++)
		if ([text containsString:[kinds[i] explicitTag]])
			return select(i);
	
	// Remove () and whitespace.  GreekVerbs are one word
	// and have one of the suffixes above.
	text = [[text stringByPurgingParentheticalText] strip];
	if (![text containsCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])
		for (int i = 0; kinds[i]; i++)
			if ([text hasSuffix:[kinds[i] suffix]])
				return select(i);
#   undef select
	
	return nil;
}

+ (NSString*) suffix
{
	return OxAbstract();
}

+ (NSString*) explicitTag
{
	return OxAbstract();
}

- (NSString*) stem:(NSString*)presentTense
{
	return [presentTense sliceTo:-[[[self class] suffix] length]]; // slice off ω
}

- (NSString*) programmaticAoristStem:(NSString*)presentTense
{
	return OxAbstract();
}

- (NSArray*) presentTenseEndings
{
	return OxAbstract();
}

- (NSArray*) pastTenseEndings
{
	return OxAbstract();
}

- (NSArray*) imperativeEndings
{
	return OxAbstract();
}

- (NSString*) metoxhEnding
{
	return OxAbstract();
}

- (NSString*) aoristStem:(NSString*)presentTense
{
	// First check if the user specified one.
	NSArray *tenseNames = [m_lang tenseNames];
	NSString *aoristosRel = [tenseNames objectAtIndex:AORISTOS];
	if ([m_word hasRelatedText:aoristosRel]) {
		// it's a little bit tricky to get from aoristos to 
		// the stem.  
		NSString *aoristos = [m_word relatedText:aoristosRel];
		
		// Start by watching out for artificial prefixes...
		NSArray *syllables = [aoristos greekSyllables];
		if ([syllables count] == 3) {
			NSArray *prefixes = GrArr("έ", "ή");
			for (NSString *prefix in prefixes)
				if ([[syllables _0] isEqual:prefix]) {
					syllables = [syllables sliceFrom:1];
					break;
				}
		}
		NSString *sansPrefix = [syllables componentsJoinedByString:@""];

		// ...then take the accent position from present tense ...
		int stress = [presentTense greekFindStress];
		
		/// ...and combine with aoristos...
		NSString *shiftedAoristos;
		if (stress) shiftedAoristos = [sansPrefix greekStringWithShiftedStress:stress];
		else shiftedAoristos = sansPrefix; // (shouldn't ever happen)
		
		// ...and then lop off the ending:
		NSString *oldEnding = firstPersonSingular([self pastTenseEndings]);
		NSArray *woEnd = changeEnding(OxArr(shiftedAoristos), oldEnding, @"");		
		return [woEnd _0];
	}
	
	return [self programmaticAoristStem:presentTense];
}

- (NSString*) participle:(NSString*)presentTense
{
	return [[self aoristStem:presentTense] stringByAppendingString:Gr("ει")];
}

- (NSString*) presentTenseWithStem:(NSString*)stem
{
	NSString *ending = firstPersonSingular([self presentTenseEndings]);
	return [stem stringByAppendingString:ending];
}

- (NSString*) pastTenseWithStem:(NSString*)stem
{	
	NSString *ending = firstPersonSingular([self pastTenseEndings]);
	NSString *complete = [stem stringByAppendingString:ending];
	
	if ([[complete greekSyllables] count] < 3)
		// XXX sometimes insert η
		complete = [Gr("ε") stringByAppendingString:complete];
	
	return [complete greekStringWithShiftedStress:3];
}

- (NSArray*) endingsForTense:(Tense)tense
{
	switch (tense) {
		default: // most things are present tense endings
			return [self presentTenseEndings];

		case DYNHTIKH:
		case AORISTOS: 
		case PARAKEIMENOS:
		case PARATATIKOS:
			return [self pastTenseEndings];
			
		case PROSTAKTIKH: 
		case SYN_PROSTAKTIKH: {
			NSArray *endings = [self imperativeEndings];
			return OxArr(OxArr([endings _0], [endings _0], [endings _0]),
						 OxArr([endings _1], [endings _1], [endings _1]));
		}
		case METOXH: {
			NSString *ending = [self metoxhEnding];
			return OxArr(OxArr(ending, ending, ending), 
						 OxArr(ending, ending, ending));
		}
	}
	
}

- (NSArray*) conjugateInTense:(Tense)tense
{
	// First check for an explicit card from the user.
	NSArray *tenseNames = [m_lang tenseNames];
	
	if ([m_word hasRelatedText:[tenseNames objectAtIndex:tense]])
		return OxArr([m_word relatedText:[tenseNames objectAtIndex:tense]]);
	
	return [self programmaticallyConjugateInTense:tense];	
}

- (NSArray*) programmaticallyConjugateInTense:(Tense)tense
{
	NSString *string = [[m_word text] stringByPurgingParentheticalText];
	NSString *presentStem = [self stem:string];
	NSString *aoristStem = [self aoristStem:string];
	NSString *whichStem = presentStem;
	
	NSArray *exw = GrArr("έχω");
	NSArray *eixa = GrArr("είχα");
	NSArray *thaExw = GrArr("θα", "έχω");
	NSArray *whichHelper = nil;
	
	switch (tense) {
		case ENESTWTAS: {
			return OxArr([self presentTenseWithStem:presentStem]);
		}
		case MELLONVTAS: whichStem = aoristStem;
		case SYN_MELLONTAS: {
			NSString *enestwtas = [self presentTenseWithStem:whichStem];
			return OxArr(Gr("θα"), enestwtas);
		}
		case YPOTAKTIKH: whichStem = aoristStem;
		case SYN_YPOTAKTIKH: {
			NSString *enestwtas = [self presentTenseWithStem:whichStem];
			return OxArr(Gr("να"), enestwtas);
		}
		case AORISTOS: whichStem = aoristStem;
		case PARATATIKOS: {
			return OxArr([self pastTenseWithStem:whichStem]);
		}
		case PROSTAKTIKH: whichStem = aoristStem;
		case SYN_PROSTAKTIKH: { // technically these have different endings!
			NSString *ending = [[self imperativeEndings] objectAtIndex:0];
			return OxArr([[whichStem stringByAppendingString:ending] greekStringWithShiftedStress:3]);
		}
		case DYNHTIKH: {
			NSArray *paratatikos = [self conjugateInTense:PARATATIKOS];
			return [GrArr("θα") arrayByAddingObjectsFromArray:paratatikos];
		}
		case YPERSYNTELIKOS: whichHelper = exw; goto perfect;
		case PARAKEIMENOS:   whichHelper = eixa; goto perfect;
		case SYNT_MELLONTAS: whichHelper = thaExw; goto perfect;
		perfect: {
			return [whichHelper arrayByAddingObject:[self participle:string]];
		}
		case METOXH: {
			return OxArr(OxFmt(@"%@%@", presentStem, [self metoxhEnding]));
		}
	}
	
	[NSException raise:@"CannotConjugate"
				format:@"Cannot conjugate %@ to tense %d", string, tense];
	return nil;
}

@end
	
@implementation GreekVerbActive

- (NSArray*) presentTenseEndings
{
	return OxArr(GrArr("ω", "εις", "ει"), GrArr("ουμε", "ετε", "ουν"));
}

- (NSArray*) pastTenseEndings
{
	return OxArr(GrArr("α", "ες", "ε"), GrArr("αμε", "ατε", "αν"));
}

- (NSArray*) imperativeEndings
{
	return OxArr(Gr("ε"), Gr("τε"));
}

@end	

@implementation GreekVerbActiveA

+ (NSString*) suffix 
{
	return Gr("ω");
}

+ (NSString*) explicitTag
{
	return @"(ActA)";
}

- (NSString*) programmaticAoristStem:(NSString*)presentTense
{
	// From modern greek grammar paragraph 701:
	NSArray *stemChanges = OxArr(// Labial sounds end in ψ:
								 GrArr("π", "ψ"),
								 GrArr("β", "ψ"),	
								 GrArr("φ", "ψ"),
								 GrArr("ευ", "εψ"),
								 GrArr("εύ", "έψ"),
								 
								 // Gutteral sounds end in ξ:
								 GrArr("κ", "ξ"),
								 GrArr("γ", "ξ"),	
								 GrArr("χ", "ξ"),
								 GrArr("χν", "ξ"),
								 
								 // Dental or sibilant sounds ed in -σ or -ξ:								 
								 //   (Have to guess here)
								 GrArr("ττ", "ξ"),
								 GrArr("τ", "σ"),
								 GrArr("σσ", "ξ"),
								 GrArr("σ", "σ"),
								 GrArr("ζ", "σ")     // often wrong, consider παίζω
								 );
	
	// Try to find an appropriate stem.  
	NSString *omega = Gr("ω");
	for (NSArray *stemChange in stemChanges) {
		NSString *suffix = OxFmt(@"%@%@", [stemChange _0], omega);
		if ([presentTense hasSuffix:suffix]) {
			return OxFmt(@"%@%@", [presentTense sliceTo:-[suffix length]], [stemChange _1]);
		}
	}
	
	// If we can't find a change to make, give up.
	return [self stem:presentTense];
}

- (NSString*) metoxhEnding
{
	return Gr("οντας");
}

@end

@implementation GreekVerbActiveB

- (NSArray*) programmaticallyConjugateInTense:(Tense)tense
{
	NSString *string = [[m_word text] stringByPurgingParentheticalText];
	if (tense == PARATATIKOS) {
		return OxArr(OxFmt(@"%@%@", [self stem:string], Gr("ούσα")));
	} else {
		return [super conjugateInTense:tense];
	}
}

- (NSString*) programmaticAoristStem:(NSString*)presentTense
{
	NSString *stem = [self stem:presentTense];
	return OxFmt(@"%@%@", stem, Gr("ησ"));
}

- (NSString*) metoxhEnding
{
	return Gr("ώντας");
}


@end

@implementation GreekVerbActiveB1

+ (NSString*) suffix 
{
	return Gr("άω");
}

+ (NSString*) explicitTag
{
	return @"(ActB1)";
}

@end

@implementation GreekVerbActiveB2

+ (NSString*) suffix 
{
	return Gr("ώ");
}

+ (NSString*) explicitTag
{
	return @"(ActB2)";
}

@end

#if 0

@interface Noun : WordCategory {} @end

@interface NounMale : Noun {} @end
@interface NounMaleOsOi : NounMale {} @end
@interface NounMaleAsEs : NounMale {} @end
@interface NounMaleHsEs : NounMale {} @end
@interface NounMaleEasEis : NounMale {} @end
@interface NounMaleHsEis : NounMale {} @end
@interface NounMaleHsAsEsOusDes : NounMale {} @end

@interface NounFemale : Noun {} @end
@interface NounFemaleHEs : NounFemale {} @end
@interface NounFemaleHEis : NounFemale {} @end
@interface NounFemaleOsOi : NounFemale {} @end
@interface NounFemaleAOu : NounFemale {} @end
@interface NounFemaleEasEis : NounFemale {} @end

@interface NounNeuter : Noun {} @end
@interface NounNeuterOA : NounNeuter {} @end
@interface NounNeuterIIa : NounNeuter {} @end
@interface NounNeuterMaMata : NounNeuter {} @end
@interface NounNeuterOsH : NounNeuter {} @end
@interface NounNeuterImoImata : NounNeuter {} @end
@interface NounNeuterAsOsWsTa : NounNeuter {} @end
@interface NounNeuterOnAnEnNta : NounNeuter {} @end
#endif

#pragma mark -
#pragma mark Quiz Question Factories
#pragma mark -

@interface GreekConjugationQuizQuestionFactory : BaseConjugationQuizQuestionFactory {
}
@end

@implementation GreekConjugationQuizQuestionFactory

- (NSArray*) promptTense
{
	NSNumber *person = OxInt(random() % 3);
	NSNumber *plural = OxInt(random() % 2);
	return OxArr(OxInt(ENESTWTAS), person, plural);
}

- (NSArray*) tensesToTest:(NSArray*)promptTense
{
	NSNumber *person = [promptTense _1];
	NSNumber *plural = [promptTense _2];
	return OxArr(OxArr(OxInt(PARATATIKOS), person, plural),
				 OxArr(OxInt(SYN_PROSTAKTIKH), person, plural),
				 OxArr(OxInt(AORISTOS), person, plural),
				 OxArr(OxInt(PROSTAKTIKH), person, plural));
}

- (NSString*) subtitle:(NSArray*)promptTense
{
	int person = [[promptTense _1] intValue];
	int plural = [[promptTense _2] intValue];
	NSString *personString = [OxArr(@"First", @"Second", @"Third") objectAtIndex:person];
	NSString *pluralString = [OxArr(@"Singular", @"Plural") objectAtIndex:plural];
	return OxFmt(@"%@ Person, %@", personString, pluralString);
}

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck {
	if ([rule hasPrefix:Gr("Ρήμα-")]) {
		// XXX
	}
	return nil;
}

@end

#pragma mark -
#pragma mark Language Object
#pragma mark -

@implementation GreekLanguage

- init
{
	if ((self = [super initFromPlistNamed:@"GreekLanguage"
								 inBundle:[NSBundle mainBundle]]))
	{
		NSMutableArray *relations = [NSMutableArray arrayWithArray:m_relations];
		for (NSString *tenseName in [self tenseNames]) {
			Relation *r = [[Relation alloc] initWithLanguage:self name:tenseName crossLanguage:NO];
			[relations addObject:r];
		}
		m_relations = relations;
	}
	return self;
}

- quizQuestionFactories
{
	return OxArr([EquivalentQuizQuestionFactory new],
				 [[GreekConjugationQuizQuestionFactory alloc] initWithLanguage:self]);
}

- (NSArray*) tenseNames 
{
	NSArray *grammarRules = [m_plist objectForKey:@"grammarRules"];	
	NSDictionary *verbs = [grammarRules _0];
	return [verbs objectForKey:@"3 Tense"];
}

- (NSArray*) relationNamesForTense:(int)tense person:(int)person plural:(int)plural
{
	return OxArr([[self tenseNames] objectAtIndex:tense]);
}

- (NSArray*) conjugate:(Word*)word person:(int)person plural:(BOOL)plural
{
	GreekVerb *verb = [GreekVerb categorize:word language:self];
	NSMutableArray *result = [NSMutableArray array];

	if (verb != nil) {
		for (int tense = 0; tense < MAX_TENSE; tense++) {
			// Conjugate into first person, singular
			NSArray *firstPerson = [verb conjugateInTense:tense];
			if (firstPerson == nil) {
				[result addObject:@"<nil>"];
				continue;
			}
			
			// Change from 1st person singular to the appropriate ending
			NSArray *endings = [verb endingsForTense:tense];
			NSString *firstPersonEnding = firstPersonSingular(endings);
			NSString *newEnding = [[endings objectAtIndex:plural] objectAtIndex:person];
			NSArray *correctPerson = changeEnding(firstPerson, firstPersonEnding, newEnding);

			// Add to resulting array
			[result addObject:[correctPerson componentsJoinedByString:@" "]];
		}
	}
	return result;
}

- (BOOL) supportsGui
{
	return YES;
}

- (NSWindowController*) createGuiController:(NSManagedObjectContext*)ctx
{
	return [[GreekLanguageController alloc] initWithLanguage:self
										managedObjectContext:ctx];
}

@end


