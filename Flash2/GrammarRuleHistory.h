//
//  GrammarRuleHistory.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "History.h"

@class LanguageVersion;

@interface GrammarRuleHistory :  History  
{
}

@property (nonatomic, retain) NSString * grammarRuleName;
@property (nonatomic, retain) LanguageVersion * languageVersion;

@end



