//
//  FrenchLanguage.h
//  Flash2
//
//  Created by Nicholas Matsakis on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Language.h"
#import "BaseLanguage.h"

@interface FrenchLanguage : BaseLanguage {
	NSArray *m_tenseNames;
}

// Returns a list of all tenses we can conjuate.
- (NSArray*) tenseNames;

// Conjugates 'word' as a verb.  Returns an array
// of strings, one for each of the tenses above!
- (NSArray*) conjugate:(Word*)word person:(int)person plural:(BOOL)plural;

- (NSArray*) articles;     // 1st person, 2nd person, 3rd person, 1st person plural, etc
- (NSArray*) relationNamesForTense:(int)tense;

@end
