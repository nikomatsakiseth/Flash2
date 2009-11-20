//
//  UpdateCardController.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UpdateCardController.h"
#import "OxCoreData.h"
#import "OxNSArray.h"
#import "Card.h"
#import "Model.h"

@implementation UpdateCardController

- initWithOldSpelling:(NSString*)oldSpelling
		  newSpelling:(NSString*)newSpelling
 managedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
	if ((self = [super initWithWindowNibName:@"UpdateCard"])) {
		m_oldSpelling = [oldSpelling copy];
		m_newSpelling = [newSpelling copy];
		m_managedObjectContext = managedObjectContext;
		self.matchingCards = [m_managedObjectContext objectsOfEntityType:E_CARD 
												 matchingPredicateFormat:@"fromStringCommit == %@ || toStringCommit == %@", 
							  m_oldSpelling, m_oldSpelling];
	}
	return self;
}

@synthesize matchingCards = a_matchingWords;
@synthesize managedObjectContext = m_managedObjectContext;

- (void) execute {
	if (![self.matchingCards isEmpty]) {
		[NSApp runModalForWindow:[self window]];
		[[self window] orderOut:self];
	}
}

- (void) updateIndexSet:(NSIndexSet*)indices {
	for (Card *card in [self.matchingCards objectsAtIndexes:indices]) {
		if ([card.fromStringCommit isEqual:m_oldSpelling])
			card.fromStringCommit = m_newSpelling;
		if ([card.toStringCommit isEqual:m_oldSpelling])
			card.toStringCommit = m_newSpelling;
	}
}

- (IBAction) dontUpdate:(id)sender {
	[NSApp stopModal];
}

- (IBAction) updateAll:(id)sender {
	[self updateIndexSet:[self.matchingCards indexSetWithAllIndices]];
	[NSApp stopModal];
}

- (IBAction) updateSelected:(id)sender {
	[self updateIndexSet:[m_matchingWordsController selectionIndexes]];
	[NSApp stopModal];
}

@end
