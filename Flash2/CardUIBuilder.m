//
//  CardUIBuilder.m
//  Flash2
//
//  Created by Nicholas Matsakis on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CardUIBuilder.h"
#import "Ox.h"
#import "FlashTextField.h"
#import "OxDebug.h"

@implementation CardUIBuilder

- initWithWindow:(NSWindow*)aWindow delegate:(id)aDelegate
{
	if ((self = [super init])) {
		window = aWindow;
		delegate = aDelegate;
	}
	return self;
}

- (NSView*) createViewForCards:(int)rows 
				 relationClass:(Class)relCls
					  oldFrame:(NSRect)oldFrame
{
	// These were determined experimentally / by playing with IB:
	const CGFloat tfHeight = 22;     // height of a standard Text Field
	const CGFloat border = 22;       // distance from left/right border
	const CGFloat horizSpacing = 8;  // horiz spacing between items in a row
	const CGFloat vertSpacing = 10;  // very spacing between rows
	
	// determine new size allocated starting with old frame:
	NSRect frame = oldFrame;
	frame.size.height = rows*tfHeight + (rows-1)*vertSpacing + 2.0*border;
	
	// determine width of one component, based on current horizontal size:
	const CGFloat componentWidth = (frame.size.width - 2.0*horizSpacing - 2.0*border)/3.0;
	
	// create view:
	NSView *questionView = [[NSView alloc] initWithFrame:frame];
	id prevTextField = nil;
	
	// Build from top down: 'row' represents number of rows 
	// located above current row.
	for (int row = 0; row < rows; row++) {
		id rowViews[3];
		
		// Position the text fields relative to origin at Lower-Left of box
		NSRect frames[3];
		int xw = componentWidth + horizSpacing;
		CGFloat currentY = frame.size.height - border - (row + 1) * tfHeight - (row) * vertSpacing;
		frames[0] = NSMakeRect(border, currentY, componentWidth, tfHeight);
		frames[1] = NSMakeRect(border+xw, currentY, componentWidth, tfHeight);
		frames[2] = NSMakeRect(border+xw+xw, currentY, componentWidth, tfHeight);
		
		// Create the views:
		rowViews[0] = [[FlashTextField alloc] initWithFrame:frames[0]];
		rowViews[1] = [[relCls alloc] initWithFrame:frames[1]];
		rowViews[2] = [[FlashTextField alloc] initWithFrame:frames[2]];
		
		// Link the text fields:
		if (prevTextField == nil) [window setInitialFirstResponder:rowViews[0]];
		else [prevTextField setNextKeyView:rowViews[0]];
		[rowViews[0] setNextKeyView:rowViews[2]];
		prevTextField = rowViews[2];
		
		// Configure resize parameters:
		[rowViews[0] setAutoresizingMask:NSViewWidthSizable|NSViewMaxXMargin];
		[rowViews[1] setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin];
		[rowViews[2] setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin];
		
		// Allow delegate to make bindings etc:
		[delegate configureRow:row views:[NSArray arrayWithObjects:rowViews count:3]];
		
		for (int i = 0; i < 3; i++)
			[questionView addSubview:rowViews[i]];
	}
	[prevTextField setNextKeyView:[window initialFirstResponder]];
	
	// Consider wrapping it in an NSScrollView
	NSScreen *mainScreen = [NSScreen mainScreen];
	NSRect screenFrame = [mainScreen frame];
	const CGFloat maxHeight = screenFrame.size.height / 2.0; // * 3.0 / 4.0;
	if (frame.size.height > maxHeight) {
		NSRect maxFrame = frame;
		maxFrame.size.height = maxHeight;
		NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:maxFrame];
		[scrollView setDocumentView:questionView];
		[scrollView setBackgroundColor:[window backgroundColor]];
		[scrollView setHasHorizontalScroller:YES];
		[scrollView setHasVerticalScroller:YES];
		return scrollView;
	}
	
	return questionView;
}

- (void) resizeBox:(NSBox*)box toCards:(int)cards relationClass:(Class)relCls
{
	NSRect oldFrame = [box frame];
	NSView *questionView = [self createViewForCards:cards relationClass:relCls oldFrame:oldFrame];
	NSRect frame = [questionView frame];	
	[box setContentView:questionView];
	
	// Resize window as needed:
	CGFloat deltaY = frame.size.height - oldFrame.size.height;
	OxLog(@"frame=(%@)", NSStringFromRect(frame));
	OxLog(@"oldFrame=(%@)", NSStringFromRect(oldFrame));
	
	// (compute new window frame)
	NSRect windowFrame = [window frame];
	windowFrame.origin.y -= deltaY;
	windowFrame.size.height += deltaY;
	
	// (adjust minimum size)
	NSSize minSize = [window minSize];
	minSize.height = windowFrame.size.height;
	[window setMinSize:minSize];
	
	// (adjust current size)
	[window setFrame:windowFrame display:YES animate:NO];		
}

- (void) resizeScrollView:(NSScrollView*)scrollView toCards:(int)cards relationClass:(Class)relCls
{
	NSRect oldFrame = [scrollView frame];
	NSView *questionView = [self createViewForCards:cards relationClass:relCls oldFrame:oldFrame];
	NSRect frame = [questionView frame];
	[scrollView setDocumentView:questionView];
	
	// Resize window as needed:
	CGFloat deltaY = frame.size.height - oldFrame.size.height;
	
	// (compute new window frame)
	NSRect windowFrame = [window frame];
	windowFrame.origin.y -= deltaY;
	windowFrame.size.height += deltaY;
	
	// (adjust minimum size)
	NSSize minSize = [window minSize];
	minSize.height = windowFrame.size.height;
	[window setMinSize:minSize];
	
	// (adjust current size)
	[window setFrame:windowFrame display:YES animate:NO];		
}

@end
