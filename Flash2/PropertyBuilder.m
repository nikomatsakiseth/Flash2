//
//  PropertyBuilder.m
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PropertyBuilder.h"


@implementation PropertyBuilder

@synthesize view;

- initWithRelationNames:(NSArray*)aRelationNames
{
	if((self = [super init])) {
		relationNames = [aRelationNames retain];
		view = [[NSView alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[relationNames release];
	[view release];
	[super dealloc];
}

@end
