//
//  LanguageVersion.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Card;
@class GrammarRule;

@interface LanguageVersion :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet* grammarRules;
@property (nonatomic, retain) NSSet* cards;

@end


@interface LanguageVersion (CoreDataGeneratedAccessors)
- (void)addGrammarRulesObject:(GrammarRule *)value;
- (void)removeGrammarRulesObject:(GrammarRule *)value;
- (void)addGrammarRules:(NSSet *)value;
- (void)removeGrammarRules:(NSSet *)value;

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)value;
- (void)removeCards:(NSSet *)value;

@end

