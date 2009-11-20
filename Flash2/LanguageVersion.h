//
//  LanguageVersion.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Card;
@class GrammarRuleHistory;

@interface LanguageVersion :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet* grammarRuleHistories;
@property (nonatomic, retain) NSSet* cards;

@end


@interface LanguageVersion (CoreDataGeneratedAccessors)
- (void)addGrammarRuleHistoriesObject:(GrammarRuleHistory *)value;
- (void)removeGrammarRuleHistoriesObject:(GrammarRuleHistory *)value;
- (void)addGrammarRuleHistories:(NSSet *)value;
- (void)removeGrammarRuleHistories:(NSSet *)value;

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)value;
- (void)removeCards:(NSSet *)value;

@end

