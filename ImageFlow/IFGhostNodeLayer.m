//
//  IFGhostNodeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFGhostNodeLayer.h"

@implementation IFGhostNodeLayer

+ (id)ghostLayerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initForNode:theNode layoutParameters:theLayoutParameters] autorelease];
}

- (CGSize)preferredFrameSize;
{
  self.outlinePath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, layoutParameters.columnWidth, 20)]; // TODO: use size obtained from NSCell's methods
  return NSSizeToCGSize(outlinePath.bounds.size);
}

- (void)drawInCurrentNSGraphicsContext;
{
  [[NSColor whiteColor] setFill];
  [outlinePath fill];
  [[NSColor blackColor] setStroke];
  [outlinePath stroke];
}

@end
