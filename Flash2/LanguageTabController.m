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

@implementation LanguageTabController

@synthesize rootView, wordPropBox, cards, searchStringTextField, cardsPredicate, wordSearchString, language;

- initWithLanguage:(Language*)aLanguage
{
	if((self = [super init])) {
		self.language = aLanguage;
		
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
	self.cardsPredicate = nil;
	self.wordSearchString = nil;
	[super dealloc];
}

- (void)awakeFromNib
{	
	searchStringTextField.keyboardIdentifier = [language keyboardIdentifier];
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

- (NSArray*)languages
{
	return [Language languages];
}

- (IBAction)addWord:(id)sender
{
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
