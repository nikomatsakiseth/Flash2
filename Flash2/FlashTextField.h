//
//  FlashTextField.h
//  Flash2
//
//  Created by Nicholas Matsakis on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OxBinder.h"

@interface FlashTextField : NSTextField {
	OxBinder *m_binder;
	NSString *a_keyboardIdentifier;
}

// Keyboard ID to use when active, 
// or nil for default.
@property(copy) NSString *keyboardIdentifier;

@end
