//
//  IFInputConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFInputConnectorLayer.h"

@implementation IFInputConnectorLayer

+ (id)inputConnectorLayerWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initForNode:theNode layoutParameters:theLayoutParameters] autorelease];
}

- (CGSize)preferredFrameSize;
{
  const float arrowSize = layoutParameters.connectorArrowSize;
  
  NSBezierPath* outline = [NSBezierPath bezierPath];
  [outline moveToPoint:NSMakePoint(arrowSize, 0)];
  [outline relativeLineToPoint:NSMakePoint(-arrowSize, arrowSize)];
  [outline relativeLineToPoint:NSMakePoint(layoutParameters.columnWidth - 2.0 * layoutParameters.nodeInternalMargin, 0)];
  [outline relativeLineToPoint:NSMakePoint(-arrowSize, -arrowSize)];
  [outline closePath];
  self.outlinePath = outline;
  
  return NSSizeToCGSize(outlinePath.bounds.size);
}

- (void)drawInCurrentNSGraphicsContext;
{
  [layoutParameters.connectorColor set];
  [self.outlinePath fill];
}

@end
