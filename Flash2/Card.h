//
//  Card.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LanguageVersion;

@interface Card :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * cardKind;
@property (nonatomic, retain) LanguageVersion * languageVersion;
@property (nonatomic, retain) NSSet* properties;

@end


@interface Card (CoreDataGeneratedAccessors)
- (void)addPropertiesObject:(NSManagedObject *)value;
- (void)removePropertiesObject:(NSManagedObject *)value;
- (void)addProperties:(NSSet *)value;
- (void)removeProperties:(NSSet *)value;

@end

