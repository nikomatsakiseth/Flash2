//
//  QuestionChooser.h
//  Flash2
//
//  Created by Niko Matsakis on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QuestionChooser : NSObject {
	NSManagedObjectContext *managedObjectContext;
	Language *language;
	ProbabilityEstimator *probabilityEstimator;
	NSArray *quizzableAndProbabilities;
}

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
					  language:(Language*)language;

/// Computes the best question to ask next.  Returns nil
/// if there is no appropriate question to ask.
- (QuizQuestion*)nextQuestion;

@end
