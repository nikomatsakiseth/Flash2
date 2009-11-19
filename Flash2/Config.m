//
//  Config.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "Config.h"
#import "Ox.h"
#import "OxNSArray.h"

// which keyboard to revert to
#define DEFAULT_KEYBOARD @"com.smallcultfollowing.Flash2.default_keyboard"

// number of seconds before we ask how hard the question was
#define TOO_EASY_INTERVAL @"com.smallcultfollowing.Flash2.too_easy_interval"

// min. number of mistakes before we end a quiz, unless we run out of cards
#define MINIMUM_QUIZ_LENGTH @"com.smallcultfollowing.Flash2.minimum_quiz_length"

// max. number of mistakes we permit on a quiz
#define MAXIMUM_QUIZ_LENGTH @"com.smallcultfollowing.Flash2.maximum_quiz_length"

void initializeDefaults() {
	TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardLayoutInputSource();
	NSString *currentKeyboardId = TISGetInputSourceProperty(currentKeyboard, kTISPropertyInputSourceID);
	CFRelease(currentKeyboard);
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaults = OxDict(currentKeyboardId FOR DEFAULT_KEYBOARD,
									OxDouble(10.0) FOR TOO_EASY_INTERVAL,
									OxInt(10) FOR MINIMUM_QUIZ_LENGTH,
									OxInt(20) FOR MAXIMUM_QUIZ_LENGTH);
	[userDefaults registerDefaults:defaults];
}

void selectDefaultKeyboard() {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *keyboardId  = [userDefaults stringForKey:DEFAULT_KEYBOARD];
	NSArray *keyboards = NSMakeCollectable(TISCreateInputSourceList(CfDict(keyboardId FOR kTISPropertyInputSourceID), NO));
	if (![keyboards isEmpty]) {
		TISInputSourceRef keyboard = (TISInputSourceRef)[keyboards objectAtIndex:0];
		TISSelectInputSource(keyboard);
	}
}

NSTimeInterval tooEasyInterval() {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults floatForKey:TOO_EASY_INTERVAL];
}

int minimumQuizLength() {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults integerForKey:MINIMUM_QUIZ_LENGTH];
}

int maximumQuizLength() {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults integerForKey:MAXIMUM_QUIZ_LENGTH];
}