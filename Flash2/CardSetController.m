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

@implementation CardSetController

@synthesize tabView;

- (void)awakeFromNib
{	
	languageTabControllers = [[NSMutableArray alloc] init];
	for(Language *language in [Language languages]) {
		LanguageTabController *cont = [[LanguageTabController alloc] initWithLanguage:language];
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
