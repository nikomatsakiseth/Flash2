//
//  TableLayout.m
//  Flash2
//
//  Created by Niko Matsakis on 2/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableLayout.h"
#import "Ox.h"

@implementation TableLayout

- initWithTotalColumns:(int)aTotalColumns
{
	if((self = [super init])) {
		totalColumns = aTotalColumns;
		constraints = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[constraints release];
	[super dealloc];
}

- (void)addConstraintThatColumns:(NSArray*)columns haveAtLeastWeight:(double)weight
{
	NSDictionary *constraint = OxDict(columns, @"columns",
									  OxInt([rowColumns count]), @"columnsCount",
									  OxDouble(weight), @"weight");
	[constraints addObject:constraint];
}

- (NSDictionary*)solveWeights
{
	NSArray *sortedConstraints = [constraints sortedArrayUsingKey:@"columnsCount"];

	NSMutableArray *results = [NSMutableArray arrayWithCapacity:totalColumns];
	NSNumber *zero = OxInt(0);
	for(int c = 0; c < totalColumns; c++)
		[results addObject:zero];
	
	for(NSDictionary *constraint in sortedConstraints) {
		NSArray *columns = [constraint objectForKey:@"columns"];
		double weight = [[constraint objectForKey:@"weight"] doubleValue];
		
		double currentSum = 0.0;
		for(NSNumber *c in columns)
			currentSum += [[result objectAtIndex:[c intValue]] doubleValue];
		
		double diff = weight - currentSum;
		if(diff > 0) {
			double perCell = diff / [columns count];
			for(NSNumber *c in columns) {
				int column = [c intValue];
				double cellWeight = [[result objectAtIndex:column] doubleValue];
				[result replaceObjectAtIndex:column withObject:OxDouble(cellWeight + perCell)];
			}			
		}
	}

	return results;
}

+ (NSArray*)computeStartsOfColumnsWeighted:(NSArray*)weights totalSpace:(double)totalSpace
{
	double totalWeight = 0.0;
	for(NSNumber *weight in weights)
		totalWeight += [weight doubleValue];
	
	double fraction = totalSpace / totalWeight;

	return [weights mappedArrayUsingBlock:^(id obj) {
		return OxDouble([obj doubleValue] * fraction);
	}];
}

@end
