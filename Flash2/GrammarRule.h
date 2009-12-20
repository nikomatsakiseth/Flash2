//
//  GrammarRule.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Quizzable.h"

@class LanguageVersion;

@interface GrammarRule :  Quizzable  
{
}

@property (nonatomic, retain) NSString * cardKind;
@property (nonatomic, retain) NSString * relationName;
@property (nonatomic, retain) LanguageVersion * languageVersion;

@end



