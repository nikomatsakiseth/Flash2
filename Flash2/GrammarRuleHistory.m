// 
//  GrammarRuleHistory.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GrammarRuleHistory.h"


@implementation GrammarRuleHistory 

@dynamic grammarRuleName;
@dynamic languageVersion;

- (NSString*) historyOfWhat 
{
	return self.grammarRuleName;
}

@end
