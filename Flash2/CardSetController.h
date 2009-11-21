//
//  CardSetController.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FlashTextField;

@interface CardSetController : NSWindowController {
	NSManagedObjectContext *managedObjectContext;
	NSTabView *tabView;
	NSMutableArray *languageTabControllers;
}
@property(retain) IBOutlet NSTabView *tabView;

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;

@end
