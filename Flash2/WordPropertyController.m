//
//  WordPropertyController.m
//  Flash2
//
//  Created by Niko Matsakis on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WordPropertyController.h"


@implementation WordPropertyController

@synthesize card, scrollView, managedObjectContext;

- (void)dealloc
{
	[binder releaseAndUnbindAll];
	self.card = nil;
	self.scrollView = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}

- (void)bind:(NSString *)binding 
	toObject:(id)observableController 
 withKeyPath:(NSString *)keyPath
	 options:(NSDictionary *)options
{
	NSSet *bindable = OxSet(@"card");
	if ([bindable containsObject:binding]) {
		if (binder == nil)
			binder = [OxBinder new];
		[binder bindKeyPath:binding
			  ofSlaveObject:self
				  toKeyPath:keyPath
			 ofMasterObject:observableController];
		return;
	}
	return [super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)setCard:(Card*)aCard
{
	[card autorelease];
	card = [aCard retain];
	
	if(aCard)
		[self createGuiForCard];
}

- (void)createGuiForCard
{
}

@end
