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

@interface WordPropertyController : NSObject {
	OxBinder *binder;
	NSManagedObjectContext *managedObjectContext;
	Card *card;
	NSScrollView *scrollView;
}
@property(retain) Card *card;
@property(retain) NSManagedObjectContext *managedObjectContext;
@property(retain) IBOutlet NSScrollView *scrollView;

@end
