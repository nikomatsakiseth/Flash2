//
//  CardSetController.m
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CardSetController.h"
#import "Language.h"
#import "LanguageTabController.h"
#import "OxCoreDataWindow.h"

@implementation CardSetController

@synthesize tabView;

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext 
			managedObjectModel:(NSManagedObjectModel*)aManagedObjectModel
{
	if((self = [super initWithWindowNibName:@"CardSet"])) {
		managedObjectContext = [aManagedObjectContext retain];
		managedObjectModel = [aManagedObjectModel retain];
	}
	return self;
}

- (void)dealloc
{
	[managedObjectContext release];
	[managedObjectModel release];
	[super dealloc];
}

- (IBAction) openDebugWindow:(id)sender
{
	[OxCoreDataWindow openedCoreDataWindowWithManagedObjectContext:managedObjectContext
												managedObjectModel:managedObjectModel];
}

- (void)awakeFromNib
{	
	languageTabControllers = [[NSMutableArray alloc] init];
	for(id<Language> language in allLanguages()) {
		LanguageTabController *cont = [[LanguageTabController alloc] initWithLanguage:language 
																 managedObjectContext:managedObjectContext];
		if(cont) {
			[languageTabControllers addObject:cont];
			
			NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:[language identifier]];
			[tabViewItem setView:cont.rootView];
			[tabViewItem setLabel:[language name]];
			[tabView addTabViewItem:tabViewItem];
			[tabViewItem release];
		}
	}
}

@end
