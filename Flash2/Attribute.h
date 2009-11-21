//
//  Attribute.h
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Language.h"
#import "UserProperty.h"

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
 An "Attribute" stores some property of a word, regardless of whether
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
	id<Language> language;
	id property;
	BOOL isUserProperty;
	NSManagedObjectContext *managedObjectContext;
}
@property(retain) id property;
@property(readwrite) BOOL isUserProperty;

@property(readonly) Card *card;
@property(readonly) NSString *relationName;
@property(retain) NSString *text;
@property(readonly) NSColor *textColor;

+ attributeWithLanguage:(id<Language>)aLanguage 
		   userProperty:(UserProperty*)userProperty
   managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;

+ attributeWithLanguage:(id<Language>)aLanguage 
		   autoProperty:(AutoProperty*)autoProperty
   managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;

- initWithLanguage:(id<Language>)aLanguage managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;
- (void)setUserProperty:(UserProperty*)userProperty;
- (void)setAutoProperty:(AutoProperty*)autoProperty;

// Invoked when the user has clicked on the Minus Sign to
// "remove" this attribute.  Returns YES if the Attribute
// was completely removed, meaning that it should also
// be removed from the GUI.
- (BOOL)remove;

@end

