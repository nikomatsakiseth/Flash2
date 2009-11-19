//
//  CardUIBuilder.h
//  Flash2
//
//  Created by Nicholas Matsakis on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Helper class for AddCardController and QuizController,
// which both build similar custom GUIs to manage the entry of 
// new cards and quiz cards.
@interface CardUIBuilder : NSObject {
	NSWindow *m_window;
	id m_delegate;
}

- initWithWindow:(NSWindow*)window delegate:(id)delegate;

// Removes the previous content of the box and recreates the GUI,
// this time with room for 'cards' cards.  Uses the class relCls
// to construct the widgets for relations: these must be some kind
// of View subtype, such as NSTextField.  Resizes the window and box
// as necessary.
//
// Returns an array of arrays.  Each subarray contains the 3 Views
// corresponding to a given card.
- (void) resizeBox:(NSBox*)box toCards:(int)cards relationClass:(Class)relCls;

@end

@interface NSObject (CardUIBuilder)

/* Sent by the CardUIBuilder to its delegate for each row: */
- (void) configureRow:(int)row views:(NSArray*)views;

@end