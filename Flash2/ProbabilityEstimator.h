//
//  ProbabilityEstimator.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"

@interface QuizzableAndProbability : NSObject {
	Quizzable *quizzable;
	BOOL inverse;
	double probabilityOfBeingCorrect;
}
@property(readonly) Quizzable *quizzable;
@property(readonly) BOOL inverse;
@property(readonly) double probabilityOfBeingCorrect;
+ quizzable:(Quizzable*)aQuizzable probabilityOfBeingCorrect:(double)aProbability inverse:(BOOL)anInverse;
@end


@interface ProbabilityEstimator : NSObject {
	NSManagedObjectContext *managedObjectContext;
}

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;

// Given an array of Quizzable* returns array of QuizzableAndProbability,
// sorted by probabilityOfBeingCorrect.
- (NSArray*)computeProbabilities:(NSArray*)aQuizzableArray; 

// 
- (void)updateQuizzable:(Quizzable*)quizzable inverse:(BOOL)isInverse correct:(double)correct;

@end
