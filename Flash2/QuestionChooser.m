//
//  QuestionChooser.m
//  Flash2
//
//  Created by Niko Matsakis on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QuestionChooser.h"

@interface QuestionChooser()
@property(retain) NSManagedObjectContext *managedObjectContext;
@property(retain) Language *language;
@property(retain) ProbabilityEstimator *probabilityEstimator;
@property(retain) NSArray *quizzableAndProbabilities;
@end

@implementation QuestionChooser

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
					  language:(Language*)aLanguage;
{
	if((self = [super init])) {
		self.managedObjectContext = aManagedObjectContext;
		self.language = aLanguage;
		self.probabilityEstimator = [[[ProbabilityEstimator alloc] initWithManagedObjectContext:managedObjectContext] autorelease];
		
		LanguageVersion *lv = [managedObjectContext languageVersionForLanguage:language];
		NSMutableArray *quizzables = [NSMutableArray array];
		[quizzables addObjectsFromSet:lv.cards];
		[quizzables addObjectsFromSet:lv.grammarRules];
		self.quizzableAndProbabilities = [probabilityEstimator computeProbabilities:quizzables];
	}
	return self;
}

- (void)dealloc
{
	self.managedObjectContext = nil;
	self.language = nil;
	self.probabilityEstimator = nil;
	self.quizzableAndProbabilities = nil;
	[super dealloc];
}

- (QuizQuestion*)nextQuestion
{
}

@end
