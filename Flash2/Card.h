//
//  Card.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CardHistory;
@class LanguageVersion;

@interface Card :  NSManagedObject  
{
}

@property (retain) NSString * toStringCommit;
@property (retain) NSString * relationName;
@property (retain) NSString * fromStringCommit;
@property (retain) NSSet* histories;
@property (retain) LanguageVersion * languageVersion;

// These synthetic properties are only used
// in the interface.  This allows us to 
// distinguish changes that the user made
// through the GUI versus changes we make
// programatically (which use xxxStringCommit).
@property (retain) NSString * fromString;
@property (retain) NSString * toString;

@end

@interface Card (CoreDataGeneratedAccessors)
- (void)addHistoriesObject:(CardHistory *)value;
- (void)removeHistoriesObject:(CardHistory *)value;
- (void)addHistories:(NSSet *)value;
- (void)removeHistories:(NSSet *)value;

@end

