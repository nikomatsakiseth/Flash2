//
//  CardSetController.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FlashTextField, Language;

@interface CardSetController : NSWindowController {
	NSTabView *tabView;
	NSMutableArray *languageTabControllers;
}
@property(retain) IBOutlet NSTabView *tabView;

@end
