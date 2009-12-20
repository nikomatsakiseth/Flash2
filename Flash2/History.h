//
//  History.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Quizzable;

@interface History :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * correct;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) Quizzable * quizzable;

@end



