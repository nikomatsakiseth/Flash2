//
//  LanguageVersion.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Card;

@interface LanguageVersion :  NSManagedObject  
{
}

@property (retain) NSString * identifier;
@property (retain) NSNumber * version;
@property (retain) NSSet* cards;

@end

@interface LanguageVersion (CoreDataGeneratedAccessors)
- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)value;
- (void)removeCards:(NSSet *)value;

@end

