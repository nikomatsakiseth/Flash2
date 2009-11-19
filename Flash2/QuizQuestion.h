//
//  QuizQuestion.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QuizQuestion : NSObject {
	NSString *m_title;
	NSString *m_subTitle;
	NSArray *m_quizCards;
}

- initWithTitle:(NSString*)title subTitle:(NSString*)subTitle quizCards:(NSArray*)quizCards;

@property (readonly) NSString *title;
@property (readonly) NSString *subTitle;
@property (readonly) NSArray *quizCards;

- (NSArray*) allRelatedCardDetails;
- (NSArray*) allQuizzedCardsInManagedObjectContext:(NSManagedObjectContext*)mctx;
- (NSArray*) allQuizzedRules;

@end
