// 
//  CardHistory.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CardHistory.h"

#import "Card.h"

@implementation CardHistory 

@dynamic card;

- (NSString*) historyOfWhat 
{
	return [NSString stringWithFormat:@"%@-%@", self.card.fromString, self.card.toString];
}

@end
