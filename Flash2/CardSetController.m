//
//  CardSetController.m
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CardSetController.h"
#import "Language.h"
#import "OxNSArray.h"
#import "Model.h"
#import "Carbon/Carbon.h"

@implementation CardSetController

@synthesize wordPropBox, cards, wordSearchString, cardsPredicate, language, searchStringTextField;

- (id)initWithWindow:(NSWindow *)window
{
	if((self = [super initWithWindow:window])) {
		self.language = [[Language languages] _0];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)awakeFromNib
{	
	[searchStringTextField bind:@"keyboardIdentifier" toObject:self withKeyPath:@"language.keyboardIdentifier" options:nil];
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
