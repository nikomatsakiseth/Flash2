//
//  UserProperty.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Quizzable.h"

@class Card;

@interface UserProperty :  Quizzable  
{
}

@property (nonatomic, retain) NSString * relationName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Card * card;

@end



