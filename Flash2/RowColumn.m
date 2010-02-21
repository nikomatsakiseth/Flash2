//
//  RowColumn.m
//  Flash2
//
//  Created by Niko Matsakis on 2/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RowColumn.h"


@implementation RowColumn
@synthesize row, column;

- initWithRow:(int)r column:(int)c
{
	if((self = [super init])) {
		row = r;
		column = c;
	}
	return self;
}

+ row:(int)r column:(int)c
{
	return [[[RowColumn alloc] initWithRow:r column:c] autorelease];
}

- (BOOL)isEqual:(id)anObject
{
	if([anObject isKindOfClass:[RowColumn class]]) {
		RowColumn *rc = anObject;
		return (row == rc.row && column == rc.column);
	}
	return NO;
}

- (NSUInteger)hash
{
	return (row << 4 + column);
}

@end
