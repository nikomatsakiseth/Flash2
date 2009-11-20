//
//  PropertyHistory.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "History.h"


@interface PropertyHistory :  History  
{
}

@property (nonatomic, retain) NSManagedObject * property;

@end



