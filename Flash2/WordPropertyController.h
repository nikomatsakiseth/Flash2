//
//  WordPropertyController.h
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"
#import "OxBinder.h"
#import "Language.h"
#import "FlashTextField.h"

@class Attribute;

@interface WordPropertyController : NSObject {
	id initialFirstResponder;
	id<Language> language;
	NSManagedObjectContext *managedObjectContext;
	Card *card;
	NSScrollView *container;
	NSMutableArray *attributes;
}
@property(retain) Card *card;
@property(retain) id<Language> language;
@property(retain) NSManagedObjectContext *managedObjectContext;
@property(retain) IBOutlet NSScrollView *container;
@property(retain) id initialFirstResponder;

- (void)addAttribute:(Attribute*)attribute;
- (void)removeAttribute:(Attribute*)attribute;
- (void)selectFirstAttribute;

@end

#pragma mark Classes Used Internally By WordPropertyController

/* An AutoProperty is like a UserProperty but
 * is not part of the Core Data database.  Rather
 * it was generated automatically.
 */
@interface AutoProperty : NSObject {
	Card *card;
	NSString *relationName;	
	NSString *text;
}
@property(retain) Card *card;
@property(copy) NSString *relationName;
@property(copy) NSString *text;
+ propertyWithCard:(Card*)aCard relationName:(NSString*)aRelationName text:(NSString*)aText;
@end

/* 
 An "Attribute" is a controller for some property of a word, regardless of whether
 this property is auto-generated or not.  In this way it is a generalization
 of both AutoProperty and UserProperty: the synonymous name "Attribute" is
 intended to allow me to distinguish attr from prop easily but convey that
 they are really the same thing.
 
 At any given point, the data for an Attribute can come from either an
 auto-generated source or a user-provided source.  Attempts to edit
 auto-generated data convert it into user-provided data.  Attempts to
 delete user-provided data convert it into auto-generated data.
 The textColor attribute (as well as isUserProperty) can be used to
 distinguish automatic from user-provided data.
 */
@interface Attribute : NSObject {
	WordPropertyController *wordPropertyController; // weak
	id<Language> language;
	id property;
	BOOL isUserProperty;
	NSManagedObjectContext *managedObjectContext;

	NSTextField *labelTextField;
	FlashTextField *textTextField;
	NSButton *addButton;
	NSButton *removeButton;
}
@property(retain) id property;
@property(readwrite) BOOL isUserProperty;

@property(readonly) Card *card;
@property(readonly) NSString *relationName;
@property(retain) NSString *text;
@property(readonly) NSColor *textColor;

@property(retain) NSTextField *labelTextField;
@property(retain) FlashTextField *textTextField;
@property(retain) NSButton *addButton;
@property(retain) NSButton *removeButton;

+ attributeWithUserProperty:(UserProperty*)userProperty
	 wordPropertyController:(WordPropertyController*)controller;

+ attributeWithAutoProperty:(AutoProperty*)userProperty
	 wordPropertyController:(WordPropertyController*)controller;

- initWithWordPropertyController:(WordPropertyController*)controller;
- (void)setUserProperty:(UserProperty*)userProperty;
- (void)setAutoProperty:(AutoProperty*)autoProperty;

// Invoked when the user has clicked on the Minus Sign to
// "remove" this attribute.  Returns YES if the Attribute
// was completely removed, meaning that it should also
// be removed from the GUI.
- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (NSArray*)components;

@end