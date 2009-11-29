//
//  WordPropertyController.m
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WordPropertyController.h"
#import "Ox.h"
#import "OxDebug.h"
#import "OxNSArray.h"
#import "OxNSTextField.h"
#import "FlashTextField.h"
#import "OxKeyValue.h"
#import "FlippedNSView.h"
#import "Config.h"

// These were determined experimentally / by playing with IB:
static const CGFloat tfHeight = 22;     // height of a standard Text Field
static const CGFloat tbBorder = 10;     // distance from top/bottom border
static const CGFloat lrBorder = 5;      // distance from left/right border
static const CGFloat horizSpacing = 8;  // horiz spacing between items in a row
static const CGFloat vertSpacing = 10;  // vert spacing between rows

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

- (void)addAttributesForRelationName:(NSString*)relationName to:(NSMutableArray*)result
{
	NSArray *userProperties = [card relatedUserProperties:relationName];
	if(![userProperties isEmpty]) {
		for(UserProperty *userProperty in userProperties) {
			Attribute *attribute = [Attribute attributeWithUserProperty:userProperty
												 wordPropertyController:self];
			[result addObject:attribute];
		}
	} else {
		NSString *text = [language autoPropertyForCard:card relationName:relationName];
		AutoProperty *autoProperty = [AutoProperty propertyWithCard:card
													   relationName:relationName
															   text:text];
		Attribute *attribute = [Attribute attributeWithAutoProperty:autoProperty
											 wordPropertyController:self];
		[result addObject:attribute];
	}
}

- (void)createGuiForAttributesAsSubviewOf:(NSView*)createdView
{
	// determine new size:
	// - keep current width
	// - derive height from number of rows to display
	// - - but no smaller than minimumHeight!
	NSSize containerSize = [container contentSize];
	const int rows = [attributes count];
	NSRect frame = NSMakeRect(0, 0, containerSize.width, 0);
	frame.size.height = rows*tfHeight + (rows-1)*vertSpacing + 2.0*tbBorder;
	createdView.frame = frame;
	
	// Images for buttons
	NSImage *addImage = [NSImage imageNamed:@"NSAddTemplate"];
	NSImage *removeImage = [NSImage imageNamed:@"NSRemoveTemplate"];
	const CGFloat buttonWidth = fmin([addImage size].width + 10, tfHeight);
	const CGFloat buttonHeight = fmin([addImage size].height + 10, tfHeight);
	
	// determine width of one component, based on current horizontal size:
	const CGFloat componentWidth = (frame.size.width - 2.0*buttonWidth - 3.0*horizSpacing - 2.0*lrBorder)/2.0;
	
	// create view:
	[createdView setAutoresizingMask:NSViewMinYMargin|NSViewWidthSizable];
	id prevResponder = initialFirstResponder;
	
	// Build from top down: 'row' represents number of rows 
	// located above current row.  Remember that our NSView uses a flipped coordinate system!
	CGFloat currentY = tbBorder;
	for(Attribute *attribute in attributes) {
		// Position the text fields relative to origin at Lower-Left of box
		NSRect frames[4];
		CGFloat buttonOffset = (tfHeight - buttonHeight) / 2;
		frames[0] = NSMakeRect(lrBorder, currentY, componentWidth, tfHeight);
		frames[1] = NSMakeRect(NSMaxX(frames[0]) + horizSpacing, currentY, componentWidth, tfHeight);
		frames[2] = NSMakeRect(NSMaxX(frames[1]) + horizSpacing, currentY + buttonOffset, buttonWidth, buttonHeight);
		frames[3] = NSMakeRect(NSMaxX(frames[2]), currentY + buttonOffset, buttonWidth, buttonHeight);
		currentY += tfHeight + vertSpacing;
		
		// Create or reposition the views:
		if(attribute.labelTextField != nil) {
			attribute.labelTextField.frame = frames[0];
			attribute.textTextField.frame = frames[1];
			attribute.addButton.frame = frames[2];
			attribute.removeButton.frame = frames[3];
		} else {
			attribute.labelTextField = [[[NSTextField alloc] initWithFrame:frames[0]] autorelease];
			[attribute.labelTextField configureIntoLabel];
			[attribute.labelTextField bind:@"value" toObject:attribute withKeyPath:@"relationName" options:nil];
			[attribute.labelTextField setAutoresizingMask:NSViewWidthSizable];

			attribute.textTextField = [[[FlashTextField alloc] initWithFrame:frames[1]] autorelease];
			[attribute.textTextField bind:@"value" toObject:attribute withKeyPath:@"text" options:OxDict(OxYES, NSContinuouslyUpdatesValueBindingOption)];
			if(![language isCrossLanguageRelation:attribute.relationName]) {
				[attribute.textTextField setKeyboardIdentifier:[language keyboardIdentifier]];
			} else {
				[attribute.textTextField setKeyboardIdentifier:defaultKeyboardIdentifier()];
			}
			[attribute.textTextField setAutoresizingMask:NSViewWidthSizable];
			
			attribute.addButton = [[[NSButton alloc] initWithFrame:frames[2]] autorelease];
			[attribute.addButton bind:@"enabled" toObject:attribute withKeyPath:@"isUserProperty" options:nil];
			[attribute.addButton setBezelStyle:NSRoundRectBezelStyle];
			[attribute.addButton setImage:addImage];
			[attribute.addButton setTarget:attribute];
			[attribute.addButton setAction:@selector(add:)];
			[attribute.addButton setAutoresizingMask:NSViewMinXMargin];
			
			attribute.removeButton = [[[NSButton alloc] initWithFrame:frames[3]] autorelease];
			[attribute.removeButton setBezelStyle:NSRoundRectBezelStyle];
			[attribute.removeButton setImage:removeImage];
			[attribute.removeButton setTarget:attribute];
			[attribute.removeButton setAction:@selector(remove:)];
			[attribute.removeButton setAutoresizingMask:NSViewMinXMargin];
			
			for(NSView *component in [attribute components])
				[createdView addSubview:component];
		} 
				
		// Link the next key views:
		[prevResponder setNextKeyView:attribute.textTextField];
		prevResponder = attribute.textTextField;				
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
	[window setFrame:windowFrame display:YES animate:YES];	
}

- (void)createGuiForCard
{
	NSSize containerSize = [container contentSize];
	
	// Don't release this array immediately,
	// because existing buttons etc may be 
	// referencing objects in it.
	[attributes autorelease];

	if(card == nil) {
		NSRect frame = NSMakeRect(0, 0, 0, 0);
		frame.size = containerSize;
		NSView *view = [[[NSView alloc] initWithFrame:frame] autorelease];
		[container setDocumentView:view];
		attributes = nil;
		return;
	}
	
	// Find relations we will need
	NSArray *relationNames = [language relationNamesForCardKind:card.cardKind];
	attributes = [[NSMutableArray alloc] initWithCapacity:[relationNames count]];
	for(NSString *relationName in relationNames)
		[self addAttributesForRelationName:relationName to:attributes];
	
	// Create the new GUI
	NSRect dummyFrame = NSMakeRect(0, 0, containerSize.width, containerSize.height);
	NSView *createdView = [[[FlippedNSView alloc] initWithFrame:dummyFrame] autorelease];
//	[createdView setWantsLayer:YES];
	[self createGuiForAttributesAsSubviewOf:createdView];
	[container setDocumentView:createdView];	
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

- (void)shiftAttributesFromIndex:(int)index direction:(CGFloat)sign
{
	CGFloat amount = (tfHeight + vertSpacing) * sign;
	
	for(int i = index, c = [attributes count]; i < c; i++) {
		Attribute *attr = [attributes objectAtIndex:i];
		for(NSView *component in [attr components]) {
			NSRect frame = component.frame;
			frame.origin.y += amount;
			component.frame = frame;
		}
	}
	
}

- (void)addAttribute:(Attribute*)existingAttribute
{
	// "Adding" an attribute is only possible when the
	// attribute is a user property.  In that case, it
	// generates a second UserProperty with the same 
	int index = [attributes indexOfObject:existingAttribute];
	
	UserProperty *userProperty = [managedObjectContext newUserPropertyForCard:card
																		 text:@"New" 
																 relationName:existingAttribute.relationName];
	Attribute *newAttribute = [Attribute attributeWithUserProperty:userProperty
									wordPropertyController:self];
	[attributes insertObject:newAttribute atIndex:index+1];
	
	NSView *createdView = [container documentView];
	[self createGuiForAttributesAsSubviewOf:createdView];
	
	NSWindow *window = [createdView window];
//	[window makeFirstResponder:newAttribute.textTextField];
}

- (void)removeAttribute:(Attribute*)attribute
{
	// Removing an attribute is a bit tricky.  It depends on
	// whether the attribute is auto-generated or not, etc.
	//
	// Rules are:
	
	// If auto-generated:
	//    This attribute should be the only
	//    attribute of its type.  To "remove" it,
	//    we add an empty user property.
	
	if(!attribute.isUserProperty) {
		attribute.text = @""; // convert to user property
		return;
	}
	
	// Otherwise, if user property:
	//    If this is the only user property, 
	//    then we switch back to automatic.
	//
	//    If not, we just remove it.  This causes
	//    the GUI to be adjusted because a slot 
	//    disappeared.
	
	// How many other attributes are there with this same relation name?
	NSArray *otherAttributes = [attributes filterWithBlock:^ int (id obj) {
		return obj != attribute && [[obj relationName] isEqual:attribute.relationName];
	}];
	
	UserProperty *userProperty = [[attribute.property retain] autorelease];
	if([otherAttributes isEmpty]) {
		// removing last user property switches it to automatic
		NSString *autoPropertyText = [language autoPropertyForCard:self.card relationName:attribute.relationName];
		[attribute setAutoProperty:[AutoProperty propertyWithCard:self.card 
													 relationName:attribute.relationName 
															 text:autoPropertyText]];		
	} else {
		// otherwise, just remove the one they asked
		for(NSView *component in [attribute components])
			[component removeFromSuperview];
		
		int index = [attributes indexOfObject:attribute];
		[attributes removeObjectAtIndex:index];
		[self shiftAttributesFromIndex:index direction:-1];
	}	
	[managedObjectContext deleteObject:userProperty];
}

- (void)selectFirstAttribute
{
	if([attributes count] >= 1) {
		Attribute *attribute = [attributes _0];
		NSWindow *window = [container window];
		[window performSelector:@selector(makeFirstResponder:) withObject:attribute.textTextField afterDelay:0];
	}	
}	

@end
										 
@implementation AutoProperty
@synthesize card, relationName, text;

+ propertyWithCard:(Card*)aCard relationName:(NSString*)aRelationName text:(NSString*)aText
{
	AutoProperty *prop = [[[self alloc] init] autorelease];
	prop.card = aCard;
	prop.relationName = aRelationName;
	prop.text = (aText ? aText : @"");
	return prop;
}

- (void)dealloc
{
	self.card = nil;
	self.relationName = nil;
	self.text = nil;
	[super dealloc];
}

@end

@implementation Attribute

@synthesize property, isUserProperty, labelTextField, textTextField, addButton, removeButton;

- initWithWordPropertyController:(WordPropertyController*)controller
{
	if((self = [super init])) {
		wordPropertyController = controller; // weak ref!
		language = [controller.language retain];
		managedObjectContext = [controller.managedObjectContext retain];
	}
	return self;
}

- (void)dealloc
{
	wordPropertyController = nil; // weak ref!
	[language release];
	[managedObjectContext release];
	self.property = nil;
	[super dealloc];
}

+ attributeWithUserProperty:(UserProperty*)userProperty
	 wordPropertyController:(WordPropertyController*)controller
{
	Attribute *attr = [[Attribute alloc] initWithWordPropertyController:controller];
	[attr setUserProperty:userProperty];
	return attr;
}

+ attributeWithAutoProperty:(AutoProperty*)autoProperty
	 wordPropertyController:(WordPropertyController*)controller
{
	Attribute *attr = [[Attribute alloc] initWithWordPropertyController:controller];
	[attr setAutoProperty:autoProperty];
	return attr;
}

- (NSString*)description
{
	return OxFmt(@"[Attr %p %@.%@=%@ (%d)]", self, self.card.text, self.relationName, self.text, self.isUserProperty);
}

- (void)setAutoProperty:(AutoProperty*)autoProperty
{
	self.property = autoProperty;
	self.isUserProperty = NO;
}

- (void)setUserProperty:(UserProperty*)userProperty
{
	self.property = userProperty;
	self.isUserProperty = YES;
}

+ (NSSet*)keyPathsForValuesAffectingCard
{
	return OxSet(@"property.card");
}

- (Card*)card
{
	return [self.property card];
}

+ (NSSet*)keyPathsForValuesAffectingRelationName
{
	return OxSet(@"property.relationName");
}

- (NSString*)relationName
{
	return [self.property relationName];
}

+ (NSSet*)keyPathsForValuesAffectingText
{
	return OxSet(@"property.text");
}

- (NSString*)text
{
	return [self.property text];
}

+ (NSSet*)keyPathsForValuesAffectingTextColor
{
	return OxSet(@"isUserProperty");
}

- (NSColor*)textColor
{
	if(isUserProperty) {
		return [NSColor blackColor];
	} else {
		return [NSColor grayColor];
	}
}

- (void)setText:(NSString*)aText
{
	if(isUserProperty) {
		[self.property setText:aText];
	} else {
		UserProperty *userProperty = [managedObjectContext newUserPropertyForCard:self.card
																			 text:aText
																	 relationName:self.relationName];
		[self setUserProperty:userProperty];
	}
}

- (IBAction)add:(id)sender
{
	[wordPropertyController addAttribute:self];
}

- (IBAction)remove:(id)sender
{
	[wordPropertyController removeAttribute:self];
}

- (NSArray*)components
{
	return OxArr(labelTextField, textTextField, addButton, removeButton);				 
}

@end
