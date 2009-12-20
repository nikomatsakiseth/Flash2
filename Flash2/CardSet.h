//
//  MyDocument.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/18/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Language.h"

@interface CardSet : NSPersistentDocument {
}

@property (readonly) NSArray *languages; // NSArray[Language]

- (id<Language>) languageForCard:(Card*)card;

@end
