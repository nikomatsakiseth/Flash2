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
#import "OxCoreDataWindow.h"

@implementation CardSet

+ (void)initialize
{
	initializeDefaults();
}

- (NSArray*)languages
{
	return allLanguages();
}

- (id<Language>) languageForCard:(Card*)card
{
	LanguageVersion *lv = card.languageVersion;
	for (id<Language> language in self.languages) {
		if ([[language identifier] isEqual:lv.identifier])
			return language;
	}
	return nil;
}

- (void)makeWindowControllers
{
	CardSetController *cont = [[CardSetController alloc] initWithManagedObjectContext:[self managedObjectContext]
																   managedObjectModel:[self managedObjectModel]];
	[self addWindowController:cont];
	[cont release];
}

@end
