#import <Cocoa/Cocoa.h>

@interface PropertyBuilder : NSObject {
	NSArray *relationNames;
	NSView *view;
}
@property(readonly) NSView *view;

- initWithRelationNames:(NSArray*)aRelationNames;

@end
