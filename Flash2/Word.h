//
//  Word.h
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Card.h"

// When making quizzes, it's not so useful to think of cards.
// Instead, we tend to think of Words, which group together
// the text of a word and the text of any cards to which it
// is related.
@interface Word : NSObject {
	Card *m_sourceCard;
	NSDictionary *m_relatedCards; // key is relation name, value is another Card where fromString == m_sourceCard.fromString.
}

- initWithCard:(Card*)card;

- (NSString*) text;

- (BOOL) hasRelatedText:(NSString*)relationName;

- (NSString*) relatedText:(NSString*)relationName; // may return nil if no such text, returns at random if many 
- (NSArray*) relatedTexts:(NSString*)relationName; // returns empty if no such text

- (NSString*) relatedText:(NSString*)relationName ifNone:(NSString*)dflt;

- (NSArray*) cardsForRelationName:(NSString*)relationName;

@end
