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
	Language *language;
	NSBox *wordPropBox;
	NSArrayController *cards;
	NSPredicate *cardsPredicate;
	NSString *wordSearchString;
	FlashTextField *searchStringTextField;
}

@property(retain) IBOutlet NSBox *wordPropBox;
@property(retain) IBOutlet NSArrayController *cards;
@property(retain) IBOutlet FlashTextField *searchStringTextField;

@property(retain) NSPredicate *cardsPredicate;       // bound in GUI
@property(copy) NSString *wordSearchString;
@property(retain) Language *language;
@property(readonly) NSArray *languages;

- (IBAction)addWord:(id)sender;
- (IBAction)deleteWord:(id)sender;
- (IBAction)seeHistory:(id)sender;
- (IBAction)startQuiz:(id)sender;

@end
