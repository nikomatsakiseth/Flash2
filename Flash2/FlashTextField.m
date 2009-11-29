//
//  FlashTextField.m
//  Flash2
//
//  Created by Nicholas Matsakis on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlashTextField.h"


@implementation FlashTextField

@synthesize keyboardIdentifier = a_keyboardIdentifier;

- (void)bind:(NSString *)binding 
	toObject:(id)observableController 
 withKeyPath:(NSString *)keyPath
	 options:(NSDictionary *)options
{
	if ([binding isEqualToString:@"keyboardIdentifier"]) {
		if (m_binder == nil)
			m_binder = [OxBinder new];
		[m_binder bindKeyPath:binding
				ofSlaveObject:self
					toKeyPath:keyPath
			   ofMasterObject:observableController];
		return;
	}
	return [super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)dealloc
{
	[m_binder release];
	[super dealloc];
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
	NSLog(@"[%p textDidBeginEditing:%@] (kb=%@)", self, notification, self.keyboardIdentifier);
	[super textDidBeginEditing:notification];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
	NSLog(@"[%p textDidEndEditing:%@] (kb=%@)", self, notification, self.keyboardIdentifier);
	[super textDidEndEditing:notification];
}

- (BOOL)textShouldBeginEditing:(NSText *)textObject
{
	NSLog(@"[%p textShouldBeginEditing:%p] (kb=%@)", self, textObject, self.keyboardIdentifier);
	return [super textShouldBeginEditing:textObject];
}

- (BOOL)textShouldEndEditing:(NSText *)textObject
{
	NSLog(@"[%p textShouldEndEditing:%@] (kb=%@)", self, textObject, self.keyboardIdentifier);
	return [super textShouldEndEditing:textObject];
}

@end
