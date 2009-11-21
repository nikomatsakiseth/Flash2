//
//  Attribute.m
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Attribute.h"
#import "Ox.h"
#import "Model.h"

@implementation AutoProperty
@synthesize card, relationName, text;

+ propertyWithCard:(Card*)aCard relationName:(NSString*)aRelationName text:(NSString*)aText
{
	AutoProperty *prop = [[[self alloc] init] autorelease];
	prop.card = aCard;
	prop.relationName = aRelationName;
	prop.text = aText;
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

@synthesize property, isUserProperty;

- initWithLanguage:(id<Language>)aLanguage managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
{
	if((self = [super init])) {
		language = [aLanguage retain];
		managedObjectContext = [aManagedObjectContext retain];
	}
	return self;
}

- (void)dealloc
{
	[language release];
	[managedObjectContext release];
	self.property = nil;
	[super dealloc];
}

+ attributeWithLanguage:(id<Language>)aLanguage 
		   userProperty:(UserProperty*)userProperty
   managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
{
	Attribute *attr = [[[Attribute alloc] initWithLanguage:aLanguage managedObjectContext:aManagedObjectContext] autorelease];
	[attr setUserProperty:userProperty];
	return attr;
}

+ attributeWithLanguage:(id<Language>)aLanguage 
		   autoProperty:(AutoProperty*)autoProperty
   managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
{
	Attribute *attr = [[[Attribute alloc] initWithLanguage:aLanguage managedObjectContext:aManagedObjectContext] autorelease];
	[attr setAutoProperty:autoProperty];
	return attr;
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

- (BOOL)remove
{
	if(self.isUserProperty) {
		// removing a user property switches it to automatic
		UserProperty *userProperty = self.property;
		NSString *autoPropertyText = [language autoPropertyForCard:self.card relationName:self.relationName];
		if(autoPropertyText)
			[self setAutoProperty:[AutoProperty propertyWithCard:self.card relationName:self.relationName text:autoPropertyText]];
		[managedObjectContext deleteObject:userProperty];
	} else {
		// to "remove" an auto-generated property we override it with empty string
		[self setText:@""];
	}
	return self.property == nil; 
}

@end
