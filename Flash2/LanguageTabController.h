//
//  LanguageTabController.h
//  Flash2
//
//  Created by Niko Matsakis on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"
#import "Language.h"

@class FlashTextField;

@interface LanguageTabController : NSObject {
	id<Language> language;
	NSManagedObjectContext *managedObjectContext;
	
	NSView *rootView;
	NSBox *wordPropBox;
	NSArrayController *cards;
	NSPredicate *cardsPredicate;
	NSString *wordSearchString;
	FlashTextField *searchStringTextField;	
}

- initWithLanguage:(id<Language>)aLanguage managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;

@property(retain) IBOutlet NSView *rootView;
@property(retain) IBOutlet NSBox *wordPropBox;
@property(retain) IBOutlet NSArrayController *cards;
@property(retain) IBOutlet FlashTextField *searchStringTextField;

@property(retain) NSPredicate *cardsPredicate;       // bound in GUI
@property(copy) NSString *wordSearchString;
@property(retain) id<Language> language;
@property(retain) NSManagedObjectContext *managedObjectContext;
@property(readonly) NSArray *languages;

- (IBAction)addWord:(id)sender;
- (IBAction)deleteWord:(id)sender;
- (IBAction)seeHistory:(id)sender;
- (IBAction)startQuiz:(id)sender;

@end
