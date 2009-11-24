//
//  WordPropertyController.m
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WordPropertyController.h"
#import "Ox.h"
#import "OxNSArray.h"
#import "OxNSTextField.h"
#import "FlashTextField.h"
#import "OxKeyValue.h"
#import "FlippedNSView.h"

@implementation WordPropertyController

@synthesize language, initialFirstResponder, card, managedObjectContext, container;

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"card.cardKind"];
	self.card = nil;
	self.container = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	invokeObservationSelector(self, keyPath, object, change, context);
}

- (void)awakeFromNib
{
	[self addObserver:self forKeyPath:@"card.cardKind" options:0 context:nil];
}

- (void)createGuiForCard
{
	NSSize containerSize = [container contentSize];
	
	if(card == nil) {
		NSRect frame = NSMakeRect(0, 0, 0, 0);
		frame.size = containerSize;
		NSView *view = [[[NSView alloc] initWithFrame:frame] autorelease];
		[container setDocumentView:view];
		return;
	}
	
	// Find relations we will need
	NSArray *relationNames = [language relationNamesForCardKind:card.cardKind];

	// These were determined experimentally / by playing with IB:
	const CGFloat tfHeight = 22;     // height of a standard Text Field
	const CGFloat tbBorder = 10;     // distance from top/bottom border
	const CGFloat lrBorder = 10;     // distance from left/right border
	const CGFloat horizSpacing = 8;  // horiz spacing between items in a row
	const CGFloat vertSpacing = 10;  // very spacing between rows
	
	// determine new size:
	// - keep current width
	// - derive height from number of rows to display
	// - - but no smaller than minimumHeight!
	const int rows = [relationNames count];
	NSRect frame = NSMakeRect(0, 0, containerSize.width, 0);
	frame.size.height = rows*tfHeight + (rows-1)*vertSpacing + 2.0*tbBorder;
	
	// determine width of one component, based on current horizontal size:
	const CGFloat componentWidth = (frame.size.width - 2.0*horizSpacing - 2.0*lrBorder)/2.0;
	
	// create view:
	NSView *createdView = [[[FlippedNSView alloc] initWithFrame:frame] autorelease];
	[createdView setAutoresizingMask:NSViewMinYMargin|NSViewWidthSizable];
	id prevResponder = initialFirstResponder;
	
	// Build from top down: 'row' represents number of rows 
	// located above current row.  Remember that our NSView uses a flipped coordinate system!
	CGFloat currentY = tbBorder;
	for(NSString *relationName in relationNames) {
		id rowViews[2];
		
		// Position the text fields relative to origin at Lower-Left of box
		NSRect frames[2];
		int xw = componentWidth + horizSpacing;
		frames[0] = NSMakeRect(lrBorder, currentY, componentWidth, tfHeight);
		frames[1] = NSMakeRect(lrBorder+xw, currentY, componentWidth, tfHeight);
		currentY += tfHeight + vertSpacing;

		// Create the views:
		rowViews[0] = [[NSTextField alloc] initWithFrame:frames[0]];
		rowViews[1] = [[FlashTextField alloc] initWithFrame:frames[1]];
		
		// Configure and set values:
		[rowViews[0] configureIntoLabel];
		[rowViews[0] setStringValue:relationName];
		if(![language isCrossLanguageRelation:relationName])
			[rowViews[1] setKeyboardIdentifier:[language keyboardIdentifier]];
		
		// Link the text fields:
		[prevResponder setNextKeyView:rowViews[1]];
		prevResponder = rowViews[1];
		
		// Configure resize parameters:
		[rowViews[0] setAutoresizingMask:NSViewWidthSizable];
		[rowViews[1] setAutoresizingMask:NSViewWidthSizable];
				
		for (int i = 0; i < 2; i++)
			[createdView addSubview:rowViews[i]];
	}
	[prevResponder setNextKeyView:initialFirstResponder];
	
	NSScreen *mainScreen = [NSScreen mainScreen];
	NSRect screenFrame = [mainScreen frame];
	const CGFloat maxHeight = screenFrame.size.height / 2.0;
	
	CGFloat oldBoxHeight = containerSize.height;
	CGFloat newBoxHeight = fmin(frame.size.height, maxHeight);
	CGFloat diffHeight = newBoxHeight - oldBoxHeight;
	
	// Compute new window frame
	NSWindow *window = [container window];
	NSRect windowFrame = [window frame];
	CGFloat oldWindowHeight = windowFrame.size.height;
	windowFrame.size.height = fmax(oldWindowHeight + diffHeight, [window minSize].height);
	windowFrame.origin.y -= (windowFrame.size.height - oldWindowHeight) / 2;

	// Add view and resize the window as needed
	[container setDocumentView:createdView];
	[window setFrame:windowFrame display:YES animate:YES];	
}

- (void)configureRow:(int)row views:(NSArray *)views
{
	[[views _0] configureIntoLabel];
}

- (void)setCard:(Card*)aCard
{
	[card autorelease];
	card = [aCard retain];	
	[self createGuiForCard];
}

- (void)observeValueForCardCardKindOfObject:(id)anObject change:(NSDictionary *)aChange context:(void*)aContext
{
	[self createGuiForCard];
}

@end
