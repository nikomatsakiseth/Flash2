//
//  LanguageTabController.m
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LanguageTabController.h"
#import "OxNSArray.h"
#import "Model.h"
#import "Carbon/Carbon.h"
#import "Language.h"
#import "FlashTextField.h"
#import "OxKeyValue.h"
#import "OxNSArrayController.h"
#import "OxNSTextField.h"

@implementation LanguageTabController

@synthesize rootView, wordPropBox, cards, searchStringTextField, cardsPredicate, wordSearchString, language, managedObjectContext;

- initWithLanguage:(id<Language>)aLanguage managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
{
	if((self = [super init])) {
		self.language = aLanguage;
		self.managedObjectContext = aManagedObjectContext;
		
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"LanguageTab" bundle:[NSBundle mainBundle]];
		if(![nib instantiateNibWithOwner:self topLevelObjects:nil]) {
			NSLog(@"Failed to load language tab!");
			[self release];
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	self.rootView = nil;
	self.wordPropBox = nil;
	self.cards = nil;
	self.searchStringTextField = nil;
	self.language = nil;
	self.managedObjectContext = nil;
	self.cardsPredicate = nil;
	self.wordSearchString = nil;
	[super dealloc];
}

- (void)awakeFromNib
{	
	searchStringTextField.keyboardIdentifier = [language keyboardIdentifier];	
	[self.cards addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	invokeObservationSelector(self, keyPath, object, change, context);
}

- (void)setWordSearchString:(NSString *)searchString
{
	wordSearchString = [searchString copy];
	
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^ BOOL (id obj, NSDictionary *bindings) {		
		Card *card = obj;
		NSRange range = [card.text rangeOfString:wordSearchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		return range.location != NSNotFound;
	}];
	self.cardsPredicate = predicate;
}

- (void)observeValueForSelectedObjectsOfObject:(id)anObject change:(NSDictionary *)aChange context:(void*)aContext
{
	// When the user changes the selected card, we have to build up the properties GUI.
	// We don't use an NSTableView because, well, they are lame and this is so much nicer!
	Card *card = [cards selectedObject];
	NSView *contentView = [[NSView alloc] initWithFrame:[wordPropBox frame]];
	if(card) {
		// TODO
	} 
	[wordPropBox setContentView:contentView];
}

- (NSArray*)languages
{
	return allLanguages();
}

- (IBAction)addWord:(id)sender
{
	NSString *cardKind = [language guessKindOfText:wordSearchString];						  
	Card *card = [managedObjectContext newCardWithText:wordSearchString kind:cardKind language:language];
	[cards setSelectedObjects:OxArr(card)];
}

- (IBAction)deleteWord:(id)sender
{	
}

- (IBAction)seeHistory:(id)sender
{
}

- (IBAction)startQuiz:(id)sender
{
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	// Determine the keyboard for this language.
	if (language) { // program defensively here... shouldn't be nil though
		NSString *languageKbId = [language keyboardIdentifier];
		NSArray *languageKbs = (NSArray*)TISCreateInputSourceList(CfDict(languageKbId FOR kTISPropertyInputSourceID), true);
		TISInputSourceRef languageKb = (TISInputSourceRef)[languageKbs anyObject];
		if (languageKb != NULL) // who knows, maybe user doesn't have this keyboard or something
			TISSelectInputSource(languageKb);
	}
	
	return YES;	
}

@end
