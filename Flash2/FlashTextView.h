//
//  FlashTextView.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface FlashTextView : NSTextView {
	NSString *m_activeIdentifier;
	NSString *m_savedIdentifier;
}

- (void) setKeyboardIdentifierToUseWhenActive:(NSString*)activeKeyboardIdentifier;

@end
