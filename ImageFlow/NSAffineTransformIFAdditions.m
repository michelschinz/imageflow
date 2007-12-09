//
//  NSAffineTransformIFAdditions.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "NSAffineTransformIFAdditions.h"

@implementation NSAffineTransform (NSAffineTransformIFAdditions)

- (void)setToIdentity;
{
  NSAffineTransformStruct ts = { 1, 0, 0, 1, 0, 0 };
  [self setTransformStruct:ts];
}

- (NSRect)transformRect:(NSRect)rect;
{
  NSAffineTransformStruct m = [self transformStruct];
  CGAffineTransform cgTransform = CGAffineTransformMake(m.m11,m.m12,m.m21,m.m22,m.tX,m.tY);
  return NSRectFromCGRect(CGRectApplyAffineTransform(CGRectFromNSRect(rect),cgTransform));
}

@end
