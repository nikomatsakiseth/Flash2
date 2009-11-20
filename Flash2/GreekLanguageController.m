//
//  GreekLanguageController.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GreekLanguageController.h"
#import "GreekLanguage.h"
#import "OxNSString.h"
#import "CardSet.h"
#import "Model.h"
#import "Ox.h"
#import "Word.h"
#import "OxNSArrayController.h"
#import "OxKeyValue.h"

@implementation GreekLanguageController

- initWithLanguage:(GreekLanguage*)lang managedObjectContext:(NSManagedObjectContext*)ctx
{
	if ((self = [super initWithWindowNibName:@"GreekLanguage"])) {
		m_lang = lang;
	}
	return self;
}

- (void) awakeFromNib
{
	[m_verbCardsController addObserver:self forKeyPath:@"selection" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	invokeObservationSelector(self, keyPath, object, change, context);
}

@synthesize language = m_lang;

@synthesize syllabizedWord = a_syllabizedWord;
- (IBAction) syllabize:(id)sender {
	NSString *word = [sender stringValue];
	NSArray *syllables = [word greekSyllables];
	self.syllabizedWord = [syllables componentsJoinedByString:@"-"];
}

@synthesize addStressedWord = a_addStressedWord;
- (IBAction) addStress:(id)sender {
	NSString *word = [sender stringValue];
	self.addStressedWord = [word greekAddStress];
}

@synthesize removeStressedWord = a_removeStressedWord;
- (IBAction) removeStress:(id)sender {
	NSString *word = [sender stringValue];
	self.removeStressedWord = [word greekRemoveStress];
}

@synthesize shiftStressedWord = a_shiftStressedWord;
- (IBAction) shiftStress:(id)sender {
	NSString *word = [sender stringValue];
	self.shiftStressedWord = [word greekStringWithShiftedStress:3];
}

@synthesize person = a_person;
@synthesize plural = a_plural;

- (NSManagedObjectContext*) managedObjectContext
{
	id document = [self document];
	return [document managedObjectContext];
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return OxFmt(@"Greek Language (%@)", displayName);
}

- (NSPredicate*) greekLanguageCards
{
	//LanguageVersion *lversion = [m_mctx languageVersionForLanguage:m_lang];
	//return [NSPredicate predicateWithFormat:@"languageVersion = %@", lversion];
	return nil;
}

- (void) observeValueForSelectionOfObject:(id)object change:(id)change context:(void*)ctx
{
	NSLog(@"GLC.observeValueForSelectionOfObject: selectionIndexes=%@", [m_verbCardsController selectionIndexes]);
	[self willChangeValueForKey:@"conjugations"];
	[self didChangeValueForKey:@"conjugations"];
}

+ (NSSet*) keyPathsForValuesAffectingConjugations
{
	// for some reason, adding .selection here didn't seem to work, and so I 
	// was forced to add the manual observer above!
	return OxSet(@"m_verbCardsController.selection", @"person", @"plural");
}

- (NSArray*) conjugations
{
	Card *selectedVerb = [m_verbCardsController selectedObject];
	if (selectedVerb == nil)
		return OxArr(nil);
	Word *word = [[Word alloc] initWithCard:selectedVerb];
	NSArray *tenseNames = [m_lang tenseNames];
	NSArray *conj = [m_lang conjugate:word person:self.person plural:self.plural];
	NSMutableArray *result = [NSMutableArray array];
	for (int i = 0; i < [conj count]; i++) {
		[result addObject:OxDict([conj objectAtIndex:i] FOR @"conjugation",
								 [tenseNames objectAtIndex:i] FOR @"tenseName")];
	}
	NSLog(@"GLC: Conjugations of %@ are %@", [word text], result);
	return result;
}

- (void) selectCard:(Card*)card
{
	NSLog(@"GLC.selectCard: selectionIndexes=%@", [m_verbCardsController selectionIndexes]);
	[m_verbCardsController setSelectedObjects:OxArr(card)];
}

@end
