//
//  GreekLanguageController.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Card.h"

@class GreekLanguage;

@interface GreekLanguageController : NSWindowController {
	NSManagedObjectContext *m_mctx;
	GreekLanguage *m_lang;
	
	NSString *a_syllabizedWord;
	NSString *a_addStressedWord;
	NSString *a_removeStressedWord;
	NSString *a_shiftStressedWord;

	IBOutlet NSArrayController *m_verbCardsController;
	int	a_person;
	int	a_plural;
}

- initWithLanguage:(GreekLanguage*)lang managedObjectContext:(NSManagedObjectContext*)ctx;

@property (readonly) GreekLanguage *language;

@property (retain) NSString *syllabizedWord;
- (IBAction) syllabize:(id)sender;

@property (retain) NSString *addStressedWord;
- (IBAction) addStress:(id)sender;

@property (retain) NSString *removeStressedWord;
- (IBAction) removeStress:(id)sender;

@property (retain) NSString *shiftStressedWord;
- (IBAction) shiftStress:(id)sender;

// a predicate that selects only cards for the greek language
@property (readonly) NSPredicate *greekLanguageCards;

// conjugations:
@property (readwrite) int person;
@property (readwrite) int plural;
@property (readonly) NSArray *conjugations;

// sent by BrowseCardController sometimes
- (void) selectCard:(Card*)card;

@property (readonly) NSManagedObjectContext *managedObjectContext;

@end
