//
//  NSAffineTransformIFAdditions.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAffineTransform (NSAffineTransformIFAdditions)

- (NSRect)transformRect:(NSRect)rect;

@end
