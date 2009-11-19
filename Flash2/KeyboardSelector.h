//
//  KeyboardSelector.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlashTextView.h"
#import "CardSet.h"

/**
 * An object that attempts to switch to the appropriate keyboard,
 * depending on what is being edited.  
 *
 * Can be used as the delegate of an NSWindow or as the delegate
 * of an NSTableView.
 */
@interface KeyboardSelector : NSObject {
	IBOutlet CardSet *m_cardSet;
	FlashTextView *m_textView;
}

- (void) setCardSet:(CardSet*)cardSet;

// Assumes the table is bound to the fromString, relationName, toString fields 
// of a Card.  Walks the bindings to automagically determine the correct
// keyboard ID.
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

// Creates and returns a field editor for anObject.  Assumes that
// [anObject tag] is set to the index of the language the field
// is in (from the languages array), or -1 for the default keyboard.
- (id)windowWillReturnFieldEditor:(NSWindow *)window 
						 toObject:(id)anObject;

@end
