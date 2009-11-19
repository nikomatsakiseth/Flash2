//
//  AddCardController.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Language.h"
#import "CardSet.h"

@interface AddCardController : NSObject {
	IBOutlet NSWindow *m_window;
	IBOutlet NSBox *m_box;
	IBOutlet CardSet *m_cardSet;
	
	NSManagedObjectContext *m_mctx;
	Language *a_language;
	NSArrayController *m_relations;
	
	NSString *a_fromString;
	NSArray *a_newCards;
}

@property (retain) Language *language;
@property (retain) NSArray *newCards;
@property (retain) NSString *fromString;
@property (readonly) NSPredicate *existingCardsPredicate;

- (IBAction) addAll:(id)sender;
- (IBAction) addRow:(id)sender;
- (IBAction) reset:(id)sender;

@end
