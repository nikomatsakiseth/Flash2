//
//  BrowseCardController.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CardSet.h"

@interface BrowseCardController : NSObject {
	IBOutlet CardSet *m_cardSet;
	IBOutlet NSArrayController *m_cards;
	NSMapTable *m_languageControllers;
}

@property (readonly) Language *cardLanguage;

- (IBAction) conjugate:(id)sender;

@end
