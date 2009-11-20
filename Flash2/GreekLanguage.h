//
//  GreekLanguage.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Language.h"
#import "BaseLanguage.h"

@interface GreekLanguage : BaseLanguage {
}

// Returns a list of all tenses we can conjuate.
- (NSArray*) tenseNames;

// Conjugates 'word' as a verb.  Returns an array
// of strings, one for each of the tenses above!
- (NSArray*) conjugate:(Card*)word person:(int)person plural:(BOOL)plural;

@end

@interface NSString (GreekLanguage)
- (NSArray*) greekSyllables;
- (NSString*) greekRemoveStress;
- (NSString*) greekAddStress; // adds stress after first vowel
- (int) greekFindStress; // returns syllable with stress, counted from end, 1 == lasy syllable, 0 == no stress
- (NSString*) greekStringWithShiftedStress:(int)syllables; // counted from end, 1 == last syllable
@end

