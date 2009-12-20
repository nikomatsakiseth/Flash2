//
//  Card.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LanguageVersion;
@class UserProperty;

@interface Card :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * cardKind;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet* properties;
@property (nonatomic, retain) LanguageVersion * languageVersion;

@end


@interface Card (CoreDataGeneratedAccessors)
- (void)addPropertiesObject:(UserProperty *)value;
- (void)removePropertiesObject:(UserProperty *)value;
- (void)addProperties:(NSSet *)value;
- (void)removeProperties:(NSSet *)value;

@end

