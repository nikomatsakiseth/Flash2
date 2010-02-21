//
//  TableLayout.h
//  Flash2
//
//  Created by Niko Matsakis on 2/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 Quiz Questions present a table of choices, and this 
 code is responsible for determining the weights
 of each cell.
 
 The input is 
 */
@interface TableLayout : NSObject {
	int totalColumns;
	NSMutableArray *constraints;
}

- initWithTotalColumns:(int)aTotalColumns;

// Constraint that sum of the weights of `rowColumns` must be at least `weight`.
- (void)addConstraintThatColumns:(NSArray*)columns haveAtLeastWeight:(double)weight;

// For each column, an NSNumber with its weight.
- (NSArray*)solveWeights;

+ (NSArray*)computeStartsOfColumnsWeighted:(NSArray*)weights totalSpace:(double)totalSpace;

@end
