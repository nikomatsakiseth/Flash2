//
//  History.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface History :  NSManagedObject  
{
}

@property (retain) NSNumber * howCorrect;
@property (retain) NSNumber * duration;
@property (retain) NSNumber * mostRecent;
@property (retain) NSDate * expirationDate;

@end


