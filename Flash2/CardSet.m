//
//  MyDocument.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "CardSet.h"
#import "Language.h"
#import "Config.h"
#import "Model.h"
#import "CardSetController.h"

@implementation CardSet

+ (void)initialize
{
	initializeDefaults();
}

- (id)init 
{
    self = [super init];
    if (self != nil) {
		a_languages = [Language languages];
		a_relations = [a_languages valueForKeyPath:@"@distinctUnionOfArrays.relations"];
    }
    return self;
}

@synthesize languages = a_languages;
@synthesize relations = a_relations;

- (NSString *)windowNibName 
{
    return @"CardSet";
}

- (Language*) languageForCard:(Card*)card
{
	LanguageVersion *lv = card.languageVersion;
	for (Language *language in self.languages) {
		if ([[language identifier] isEqual:lv.identifier])
			return language;
	}
	return nil;
}

- (IBAction) openDebugWindow:(id)sender
{
}

- (void)makeWindowControllers
{
	CardSetController *cont = [[CardSetController alloc] initWithWindowNibName:[self windowNibName]];
	[self addWindowController:cont];
	[cont release];
}

@end
