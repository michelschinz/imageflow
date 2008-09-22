//
//  IFHighlightLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorHighlightLayer.h"

#import "IFLayoutParameters.h"

@implementation IFConnectorHighlightLayer

+ (id)highlightLayer;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  CGPathRelease(outlinePath);
  [super dealloc];
}

- (CGPathRef)outlinePath;
{
  return outlinePath;
}

- (void)setOutlinePath:(CGPathRef)newOutlinePath;
{
  if (newOutlinePath == outlinePath)
    return;
  CGPathRelease(outlinePath);
  outlinePath = CGPathRetain(newOutlinePath);
  
  [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)context;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  CGContextAddPath(context, outlinePath);
  
  CGContextSetFillColorWithColor(context, layoutParameters.highlightColor);
  CGContextFillPath(context);
  
  CGContextSetStrokeColorWithColor(context, layoutParameters.highlightColor);
  CGContextSetLineWidth(context, layoutParameters.selectionWidth);
  CGContextStrokePath(context);
}

@end
