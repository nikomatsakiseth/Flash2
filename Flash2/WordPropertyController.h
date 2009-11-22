//
//  WordPropertyController.h
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"
#import "OxBinder.h"
#import "Language.h"

@interface WordPropertyController : NSObject {
	id initialFirstResponder;
	id<Language> language;
	NSManagedObjectContext *managedObjectContext;
	Card *card;
	NSScrollView *container;
}
@property(retain) Card *card;
@property(retain) id<Language> language;
@property(retain) NSManagedObjectContext *managedObjectContext;
@property(retain) IBOutlet NSScrollView *container;
@property(retain) id initialFirstResponder;


@end
