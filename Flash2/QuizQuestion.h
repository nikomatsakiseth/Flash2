//
//  QuizQuestion.h
//  Flash2
//
//  Created by Niko Matsakis on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// XXX Design:
//     
//     A Q.Q. should be a grid of labels and forms.
//     Each form has an id string.
//
//     For each of these ids, Q.Q. there are 
//     a set of QuizAnswers.
//
//     Each QuizAnswer has the expected input as
//     well as the Quizzables/Words/Relationships etc
//     that were used (or could have been used) to 
//     derive it.
@interface QuizQuestion : NSObject {
	
}

@end
