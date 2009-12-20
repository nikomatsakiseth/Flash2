//
//  Quizzable.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class History;

@interface Quizzable :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * lastQuizzed;
@property (nonatomic, retain) NSSet* histories;

@end


@interface Quizzable (CoreDataGeneratedAccessors)
- (void)addHistoriesObject:(History *)value;
- (void)removeHistoriesObject:(History *)value;
- (void)addHistories:(NSSet *)value;
- (void)removeHistories:(NSSet *)value;

@end

