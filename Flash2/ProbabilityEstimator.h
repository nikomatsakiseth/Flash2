//
//  ProbabilityEstimator.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"

@interface ProbabilityEstimator : NSObject {
	NSManagedObjectContext *managedObjectContext;
}

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;
- (double)probablyOfCorrectlyAnswering:(Quizzable*)quizzable;
- (void)updateQuizzable:(Quizzable*)quizzable correct:(double)correct;

@end
