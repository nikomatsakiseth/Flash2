//
//  LanguageDefn.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Language.h"
#import "OxNSArray.h"
#import "GreekLanguage.h"
#import "FrenchLanguage.h"
#import "Ox.h"
#import "OxNSString.h"
#import "OxNSObject.h"

@implementation Language

+ (NSArray*) languages {
	return OxArr([GreekLanguage new], [FrenchLanguage new]);
}

- initWithName:(NSString*)name
	identifier:(NSString*)identifier
	 relations:(NSArray*)rels
  grammarRules:(NSArray*)rules
quizConfigurationKeys:(NSArray*)keys
  keyboardIdentifier:(NSString*)keyboardIdentifier
{
	if ((self = [super init])) {
		m_name = [name copy];
		m_identifier = [identifier copy];
		m_relations = [rels copy];
		m_grammarRules = [rules copy];
		m_quizConfigurationKeys = [keys copy];
		m_keyboardIdentifier = [keyboardIdentifier copy];
	}
	return self;
}

- initFromPlistNamed:(NSString*)plistName
			inBundle:(NSBundle*)bundle
{
	m_plist = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:plistName
																		  ofType:@"plist"]];
	if (m_plist == nil)
		return nil;
	
	NSMutableArray *relations = [NSMutableArray array];
	for (NSDictionary *relationData in [m_plist objectForKey:@"relations"]) {
		Relation *r = [[Relation alloc] initWithLanguage:self
													name:[relationData valueForKey:@"name"]
										   crossLanguage:[[relationData valueForKey:@"crossLanguage"] boolValue]];
		[relations addObject:r];
	}

	return [self initWithName:[m_plist objectForKey:@"name"] 
				   identifier:[m_plist objectForKey:@"identifier"]
					relations:relations
				 grammarRules:[[m_plist objectForKey:@"grammarRules"] expandGrammarRules]
		quizConfigurationKeys:[m_plist objectForKey:@"quizConfigurationKeys"]
				 keyboardIdentifier:[m_plist objectForKey:@"keyboardIdentifier"]];
}

- (NSString*) protocolVersion
{
	return FLASH2_PROTOCOL_V1;	
}

- (int) languageVersion
{
	return 0;
}

- (NSDictionary*) upgradeData:(NSDictionary*)data
		  fromLanguageVersion:(int)version
{
	return data; // XXX throw exception
}

- (NSString*) name
{
	return m_name;
}

- (NSString*) identifier
{
	return m_identifier;
}

- (NSString*) keyboardIdentifier
{
	return m_keyboardIdentifier;
}

- (NSArray*) grammarRules
{
	return m_grammarRules;
}

- (NSArray*) relations
{
	return m_relations;
}

- (Relation*) relationNamed:(NSString*)name
{
	for (Relation *rel in [self relations]) {
		if ([[rel name] isEqualToString:name])
			return rel;
	}
	return nil;
}

- (NSArray*) quizConfigurationKeys
{
	return m_quizConfigurationKeys;
}

// abstract, basically
- (NSArray*) quizQuestionFactories
{
	return [NSArray array];
}

- (BOOL) supportsGui
{
	return NO;
}

- (NSWindowController*) createGuiController:(NSManagedObjectContext*)ctx
{
	return nil;
}

@end

@implementation Relation

- initWithLanguage:(Language*)language name:(NSString*)name crossLanguage:(BOOL)crossLanguage 
{
	if ((self = [super init])) {
		m_language = language;
		m_name = [name copy];
		m_crossLanguage = crossLanguage;
	}
	return self;
}

@synthesize language = m_language;
@synthesize name = m_name;
@synthesize crossLanguage = m_crossLanguage;

- (NSString*) toStringKeyboardIdentifier 
{
	if (m_crossLanguage)
		return nil;
	return [self.language keyboardIdentifier];
}

@end

@implementation QuizQuestionFactory

- (QuizQuestion*) makeQuestionForRule:(NSString*)rule deck:(Deck*)deck {
	return nil;
}

- (QuizQuestion*) makeQuestionForRelationNamed:(NSString*)relationName ofWord:(Word*)word deck:(Deck*)deck {
	return nil;
}

@end

#pragma mark -
#pragma mark Plist Expansion Rules

// See header file

@implementation NSString (LanguagePlistExpansion)
- (NSArray*) expandGrammarRules {
	return OxArr(self);
}
@end

@implementation NSDictionary (LanguagePlistExpansion)
void expand(NSMutableArray *base, NSMutableArray *into, NSArray *remainingEntries) {
	if ([remainingEntries isEmpty]) 
		[into addObject:[base componentsJoinedByString:@"-"]];
	else {
		NSArray *entry = [remainingEntries objectAtIndex:0];
		remainingEntries = [remainingEntries sliceFrom:1];
		for (NSString *str in entry) {
			int index = [base count];
			[base insertObject:str atIndex:index];
			expand(base, into, remainingEntries);
			[base removeObjectAtIndex:index];
		}
	}
}

- (NSArray*) expandGrammarRules {
	NSMutableArray *expandedValues = [NSMutableArray array];
	for (NSString *prefix in [[self allKeys] sortedArrayUsingSelector:@selector(compare:)])
		[expandedValues addObject:[[self objectForKey:prefix] expandGrammarRules]];
	
	NSMutableArray *result = [NSMutableArray array];	
	expand([NSMutableArray array], result, expandedValues);	
	return result;
}
@end

@implementation NSArray (LanguagePlistExpansion)
- (NSArray*) expandGrammarRules {
	// Need to combine one entry from each of the expanded entries.
	NSMutableArray *result = [NSMutableArray array];
	for(id entry in self)
		[result addObjectsFromArray:[entry expandGrammarRules]];
	return result;
}
@end
