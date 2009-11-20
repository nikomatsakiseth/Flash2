//
//  KeyboardSelector.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeyboardSelector.h"
#import "Ox.h"
#import "Language.h"
#import "Carbon/Carbon.h"
#import "OxNSArray.h"
#import "Language.h"
#import "Config.h"
#import "OxNSString.h"

@implementation KeyboardSelector

- (void) dealloc
{
	[textView release];
	[super dealloc];
}

void logBindings(NSString *name, id object) {
	NSLog(@"%@ -----------------------------------------", name);
	for (id binding in [object exposedBindings]) {//[NSArray arrayWithObjects:@"value", @"content", @"selectedObject", nil]) {
		NSLog(@"attempting binding %@ of %@", binding, object);
		NSDictionary *bindingInfo = [object infoForBinding:binding];
		if (bindingInfo != nil) {
			for (id key in [bindingInfo allKeys])
				NSLog(@"  Key=%@ Value=%@", key, [bindingInfo objectForKey:key]);
		} else {
			NSLog(@"  not bound");
		}
	}
}

static id boundObject(id object, id binding) {
	NSDictionary *bindingInfo = [object infoForBinding:binding];
	if (bindingInfo != nil) {
		id object = [bindingInfo valueForKey:NSObservedObjectKey];
		id keyPath = [bindingInfo valueForKey:NSObservedKeyPathKey];
		return [object valueForKeyPath:keyPath];
	}
	return nil;
}

- (id)windowWillReturnFieldEditor:(NSWindow *)window 
						 toObject:(id)anObject 
{
	if ([anObject isKindOfClass:[NSTableView class]])
		return nil; // weird stuff happens
	
	//NSLog(@"windowWillReturnFieldEditorToObject: %@ (tag = %d)", anObject, [anObject tag]);
	if (textView == nil) {
		textView = [[FlashTextView alloc] initWithFrame:[anObject frame]];
		[textView setFieldEditor:YES];
	}
	
	// Is this object configured to switch into the language's keyboard?
	NSString *keyboardIdentifier;
	if ([anObject respondsToSelector:@selector(keyboardIdentifier)])
		keyboardIdentifier = [anObject keyboardIdentifier];
	else
		keyboardIdentifier = nil;
	[textView setKeyboardIdentifierToUseWhenActive:keyboardIdentifier];
	
	return textView;
}

@end
