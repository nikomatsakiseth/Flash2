//
//  Word.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Word.h"
#import "Queries.h"
#import "OxNSMutableDictionary.h"
#import "Ox.h"

@implementation Word

- initWithCard:(Card*)card
{
	if ((self = [super init])) {
		m_sourceCard = card;
		
		NSMutableDictionary *relatedDict = [NSMutableDictionary dictionary];		
		NSManagedObjectContext *ctx = [m_sourceCard managedObjectContext];
		NSArray *relatedCards = [ctx cardsWithFromString:card.fromString languageVersion:card.languageVersion];
		for (Card *relatedCard in relatedCards) {
			//if (relatedCard == m_sourceCard) continue;
			[relatedDict addObject:relatedCard toMutableArrayForKey:relatedCard.relationName];
		}
		m_relatedCards = relatedDict;
	}
	return self;
}

+ (NSSet*) keyPathsForValuesAffectingText {
	return OxSet(@"m_sourceCard.fromString");
}

- (NSString*) text
{
	return m_sourceCard.fromString;
}

- (BOOL) hasRelatedText:(NSString*)relationName
{
	return [m_relatedCards objectForKey:relationName] != nil;
}

- (NSString*) relatedText:(NSString*)relationName ifNone:(NSString*)dflt
{
	if ([self hasRelatedText:relationName])
		return [self relatedText:relationName];
	return dflt;
}

- (NSString*) relatedText:(NSString*)relationName
{
	return [[[m_relatedCards objectForKey:relationName] anyObject] toString];
}

- (NSArray*) relatedTexts:(NSString*)relationName
{
	return [[m_relatedCards objectForKey:relationName] valueForKey:K_TO_STRING];
}

- (NSArray*) cardsForRelationName:(NSString*)relationName
{
	return [m_relatedCards objectForKey:relationName];
}

@end
