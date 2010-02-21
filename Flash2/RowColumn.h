//
//  RowColumn.h
//  Flash2
//
//  Created by Niko Matsakis on 2/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RowColumn : NSObject {
	int row, column;
}
@property(readonly) int row;
@property(readonly) int column;
+ row:(int)r column:(int)c;
@end
