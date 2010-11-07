//
//  IFPathLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 21.06.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFPathLayer.h"


@implementation IFPathLayer

- (id)init;
{
  if (![super init])
    return nil;
  self.fillColor = CGColorGetConstantColor(kCGColorClear);
  self.strokeColor = CGColorGetConstantColor(kCGColorClear);
  self.needsDisplayOnBoundsChange = YES;
  return self;
}

- (void)dealloc;
{
  CGColorRelease(fillColor);
  CGColorRelease(strokeColor);
  CGPathRelease(path);
  [super dealloc];
}

@synthesize path;

- (void)setPath:(CGPathRef)newPath;
{
  if (newPath == path)
    return;
  CGPathRelease(path);
  path = CGPathRetain(newPath);

  self.bounds = CGPathGetBoundingBox(path);
  [self setNeedsDisplay];
}

@synthesize lineWidth, strokeColor;

- (void)setStrokeColor:(CGColorRef)newColor;
{
  if (newColor == strokeColor)
    return;
  CGColorRelease(strokeColor);
  strokeColor = CGColorRetain(newColor);
}

@synthesize fillColor;

- (void)setFillColor:(CGColorRef)newColor;
{
  if (newColor == fillColor)
    return;
  CGColorRelease(fillColor);
  fillColor = CGColorRetain(newColor);
}

- (void)drawInContext:(CGContextRef)context;
{
  CGContextAddPath(context, path);

  CGContextSetFillColorWithColor(context, fillColor);
  CGContextFillPath(context);

  CGContextSetStrokeColorWithColor(context, strokeColor);
  CGContextSetLineWidth(context, lineWidth);
  CGContextStrokePath(context);
}

@end
