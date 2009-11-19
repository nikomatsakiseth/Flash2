// 
//  Card.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Card.h"

#import "CardHistory.h"
#import "LanguageVersion.h"
#import "UpdateCardController.h"

#import "Ox.h"

@implementation Card 

@dynamic toStringCommit;
@dynamic relationName;
@dynamic fromStringCommit;
@dynamic histories;
@dynamic languageVersion;

+ (NSSet*) keyPathsForValuesAffectingFromString {
    return [NSSet setWithObject:@"fromStringCommit"];
}

- (NSString*) fromString {
	return self.fromStringCommit;
}

+ (NSSet*) keyPathsForValuesAffectingToString {
    return [NSSet setWithObject:@"toStringCommit"];
}

- (NSString*) description {
	return OxFmt(@"<%@ -%@-> %@>", self.fromStringCommit, self.relationName, self.toStringCommit);
}

- (NSString*) toString {
	return self.toStringCommit;
}

void userSetString(id self, SEL getSel, SEL setSel, NSString *string) {
	NSString *oldString = [self performSelector:getSel];
	if ([oldString isEqual:string])
		return; // no change required
	
	[self performSelector:setSel withObject:string];
	
	UpdateCardController *ucc = [[UpdateCardController alloc] initWithOldSpelling:oldString 
																	  newSpelling:string 
															 managedObjectContext:[self managedObjectContext]];
	[ucc execute];
}

- (void) setFromString:(NSString*)string {
	userSetString(self, @selector(fromStringCommit), @selector(setFromStringCommit:), string);
}

- (void) setToString:(NSString*)string {
	userSetString(self, @selector(toStringCommit), @selector(setToStringCommit:), string);
}

@end
