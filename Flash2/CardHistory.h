//
//  CardHistory.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "History.h"

@class Card;

@interface CardHistory :  History  
{
}

@property (retain) Card * card;

@property (readonly) NSString * historyOfWhat;

@end


