//
//  BrowseCardController.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BrowseCardController.h"
#import "OxNSArrayController.h"
#import "Ox.h"
#import "OxDebug.h"

@implementation BrowseCardController

- init {
	if ((self = [super init])) {
		m_languageControllers = [NSMapTable mapTableWithStrongToStrongObjects];
	}
	return self;
}

+ (NSSet*) keyPathsForValuesAffectingCardLanguage
{
	return OxSet(@"m_cards.selection");
}

- (Language*) cardLanguage
{
	Card *card = [m_cards selectedObject];
	if (card == nil) return nil;
	return [m_cardSet languageForCard:card];
}

- (IBAction) conjugate:(id)sender 
{	
	Language *cardLanguage = self.cardLanguage;
	if (cardLanguage == nil) return;
	
	NSWindowController *controller = [m_languageControllers objectForKey:cardLanguage];
	if (controller == nil) {
		controller = [cardLanguage createGuiController:[m_cardSet managedObjectContext]];
		[m_languageControllers setObject:controller forKey:cardLanguage];
		[m_cardSet addWindowController:controller];
	}
	
	if ([controller respondsToSelector:@selector(selectCard:)])
		[controller performSelector:@selector(selectCard:) withObject:[m_cards selectedObject]];
	[controller showWindow:self];
}

@end
