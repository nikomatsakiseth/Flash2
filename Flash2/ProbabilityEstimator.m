//
//  ProbabilityEstimator.m
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProbabilityEstimator.h"
#import "OxCoreData.h"
#import "OxNSNumber.h"

#define TI_SECOND 1.0
#define TI_MINUTE (TI_SECOND * 60.0)
#define TI_HOUR (TI_MINUTE * 60.0)
#define TI_HALF_DAY (TI_HOUR * 12.0)
#define TI_DAY (TI_HOUR * 24.0)
#define TI_WEEK (TI_DAY * 7.0)

typedef struct Ratio {
	double total;
	double correct;
} Ratio;

@implementation ProbabilityEstimator

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
{
	if((self = [super init])) {
		managedObjectContext = [aManagedObjectContext retain];
	}
	return self;
}

- (void)dealloc
{
	[managedObjectContext release];
	[super dealloc];
}

// We approximate a time interval by the number of 12-hour
// periods contained within. Why 12 hours? I don't know, why not?
// We still store it in seconds, though, to allow us to change this
// interval in the future if desired.
- (NSTimeInterval)approximateTimeInterval:(NSTimeInterval)timeInterval
{
	return round(timeInterval / TI_HALF_DAY) * TI_HALF_DAY;
}

- (Ratio)totalHistories:(id)histories fromTime:(NSTimeInterval)min untilTime:(NSTimeInterval)max
{
	Ratio r = { 0.0, 0.0 };
	for(History *history in histories) {
		double duration = [history.duration doubleValue];			   
		if(duration >= min && duration <= max) {
			r.total += [history.total doubleValue];
			r.correct += [history.correct doubleValue]; 
		}
	}
	return r;
}

- (double)probablyOfCorrectlyAnswering:(Quizzable*)quizzable
{
	/*
	 Try to estimate chance of correctly answering a given
	 word.  This could be vastly improved but it'll do for now.
	 */
	
	const double threshold = 5.0;
	
	if(quizzable.lastQuizzed != nil) {
		NSTimeInterval sinceLastQuizzed = [quizzable.lastQuizzed timeIntervalSinceNow];
		sinceLastQuizzed = [self approximateTimeInterval:sinceLastQuizzed];	
		NSTimeInterval range = fmin(sinceLastQuizzed * (2 * TI_DAY / TI_WEEK), TI_DAY);

		// Check the history of this word, trying to gather up some data:
		for(double multiple = 1; multiple <= 4; multiple += 1.0) {
			NSTimeInterval min = sinceLastQuizzed - range * multiple;
			NSTimeInterval max = sinceLastQuizzed + range * multiple;
			Ratio quizzableRatio = [self totalHistories:quizzable.histories fromTime:min untilTime:max];	
			if(quizzableRatio.total >= threshold) {
				return quizzableRatio.correct / quizzableRatio.total;
			}
		}
	
		// Not enough word-specific data!  Gather up all histories.	
		NSArray *allHistories = [managedObjectContext allObjectsOfEntityType:E_HISTORY];	
		NSTimeInterval min = sinceLastQuizzed - range;
		NSTimeInterval max = sinceLastQuizzed + range;
		Ratio allInRange = [self totalHistories:allHistories fromTime:min untilTime:max];		
		if(allInRange.total >= threshold) {
			return allInRange.correct / allInRange.total;
		} 
	} 
	
	// No relevant data at all.  Take a stab in the dark.
	return 0.5;
}

- (void)updateQuizzable:(Quizzable*)quizzable correct:(double)correct
{
	NSDate *lastQuizzed = quizzable.lastQuizzed;
	NSDate *now = [NSDate date];
	
	NSTimeInterval duration;
	if(lastQuizzed) {
		duration = [self approximateTimeInterval:[lastQuizzed timeIntervalSinceNow]];
	} else {
		duration = 0;
	}
	
	quizzable.lastQuizzed = now;
	
	// Look for and update any existing history with the
	// same duration.  Be robust against rounding errors
	// by looking for one within a minute.
	for(History *history in quizzable.histories) {
		double historyDuration = [history.duration doubleValue];
		if(fabs(duration - historyDuration) < TI_MINUTE) { 
			history.total = [history.total numberByAddingDouble:1.0];
			history.correct = [history.correct numberByAddingDouble:correct];
			return;
		}
	}
	
	[managedObjectContext newHistoryWithQuizzable:quizzable
										 duration:duration
										  correct:correct];
}

@end
