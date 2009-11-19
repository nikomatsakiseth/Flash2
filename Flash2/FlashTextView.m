//
//  FlashTextView.m
//  Flash2
//
//  Created by Nicholas Matsakis on 11/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlashTextView.h"
#import "Ox.h"
#import "OxNSArray.h"
#import "OxDebug.h"

TISInputSourceRef CopyKbWithIdentifier(NSString *identifier) {
	CFArrayRef kbRefs = TISCreateInputSourceList(CfDict(identifier FOR kTISPropertyInputSourceID), true);
	TISInputSourceRef ref = (TISInputSourceRef) CFArrayGetValueAtIndex(kbRefs, 0);
	CFRetain(ref);
	CFRelease(kbRefs);
	return ref;
}	

@implementation FlashTextView

- (void) setKeyboardIdentifierToUseWhenActive:(NSString*)activeKbId {
	m_activeIdentifier = activeKbId;
}

- (BOOL)becomeFirstResponder
{
	if (m_activeIdentifier != NULL) {
		TISInputSourceRef current = TISCopyCurrentKeyboardInputSource();
		m_savedIdentifier = TISGetInputSourceProperty(current, kTISPropertyInputSourceID);
		CFRelease(current);
		
		OxLog(@"%p: becomeFirstResponse, saving input source '%@' and selecting '%@'", 
			  self, m_savedIdentifier, m_activeIdentifier);
		
		TISInputSourceRef active = CopyKbWithIdentifier(m_activeIdentifier);
		TISSelectInputSource(active);		
		CFRelease(active);
	}
	return YES;
}

- (BOOL)resignFirstResponder
{
	if (m_savedIdentifier != NULL) {
		OxLog(@"%p: resignFirstResponse, restoring input source '%@'",
			  self, m_savedIdentifier);
		
		TISInputSourceRef saved = CopyKbWithIdentifier(m_savedIdentifier);
		TISSelectInputSource(saved);		
		CFRelease(saved);
	}
	return YES;
}

@end
