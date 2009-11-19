//
//  UpdateCardController.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// An UpdateCardController is created when it is
// detected that the user changed the spelling of a word
// on a card, but there are already existing cards 
// that had the same spelling.
@interface UpdateCardController : NSWindowController {
	NSString *m_oldSpelling;
	NSString *m_newSpelling;
	NSManagedObjectContext *m_managedObjectContext;
	NSArray *a_matchingWords;
	IBOutlet NSArrayController *m_matchingWordsController;
}

- initWithOldSpelling:(NSString*)oldSpelling
		  newSpelling:(NSString*)newSpelling
 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@property (retain) NSArray *matchingCards;
@property (readonly) NSManagedObjectContext *managedObjectContext;

- (void) execute;

- (IBAction) dontUpdate:(id)sender;
- (IBAction) updateAll:(id)sender;
- (IBAction) updateSelected:(id)sender;

@end
