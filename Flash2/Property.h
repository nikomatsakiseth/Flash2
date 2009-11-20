//
//  Property.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Card;
@class PropertyHistory;

@interface Property :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * relationName;
@property (nonatomic, retain) Card * card;
@property (nonatomic, retain) NSSet* propertyHistories;

@end


@interface Property (CoreDataGeneratedAccessors)
- (void)addPropertyHistoriesObject:(PropertyHistory *)value;
- (void)removePropertyHistoriesObject:(PropertyHistory *)value;
- (void)addPropertyHistories:(NSSet *)value;
- (void)removePropertyHistories:(NSSet *)value;

@end

