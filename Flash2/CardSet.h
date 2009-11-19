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
	NSArray *a_languages;
	NSArray *a_relations;
}

@property (readonly) NSArray *languages; // NSArray[Language]
@property (readonly) NSArray *relations; // NSArray[Relation]

- (Language*) languageForCard:(Card*)card;

- (IBAction) openDebugWindow:(id)sender;

@end
