//
//  IFOutputConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFOutputConnectorLayer.h"
#import "IFLayoutParameters.h"

@implementation IFOutputConnectorLayer

- (id)initForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  if (![super initForNode:theNode kind:theKind])
    return nil;
  
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  labelLayer = [CATextLayer layer];
  labelLayer.anchorPoint = CGPointZero;
  labelLayer.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + 1.0, CGRectGetWidth(self.frame), layoutParameters.labelFontHeight);
  labelLayer.autoresizingMask = kCALayerWidthSizable;
  labelLayer.font = layoutParameters.labelFont;
  labelLayer.fontSize = layoutParameters.labelFont.pointSize;
  labelLayer.foregroundColor = layoutParameters.connectorLabelColor;
  labelLayer.alignmentMode = kCAAlignmentCenter;
  labelLayer.truncationMode = kCATruncationMiddle;
  [self addSublayer:labelLayer];
  
  return self;
}

- (NSString*)label;
{
  return labelLayer.string;
}

- (void)setLabel:(NSString*)newLabel;
{
  labelLayer.string = newLabel;
}

@synthesize leftReach;

- (void)setLeftReach:(float)newLeftReach;
{
  if (newLeftReach != leftReach)
    [self setNeedsDisplay];
  leftReach = newLeftReach;
}

@synthesize rightReach;

- (void)setRightReach:(float)newRightReach;
{
  if (newRightReach != rightReach)
    [self setNeedsDisplay];
  rightReach = newRightReach;
}

- (CGPathRef)createOutlinePath;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float margin = layoutParameters.nodeInternalMargin;
  const float arrowSize = layoutParameters.connectorArrowSize;
  const float internalWidth = forcedFrameWidth - (leftReach + rightReach + 2.0 * margin);
  const float textHeight = [labelLayer preferredFrameSize].height;
  
  float totalLeftLength = 2.0 * margin + leftReach;
  float totalRightLength = 2.0 * margin + rightReach;
  
  // Build the path in a clockwise direction, starting from the bottom-left corner (put at the origin)
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 0);
  CGPathAddLineToPoint(path, NULL, 0, textHeight + 2.0);
  CGPathAddLineToPoint(path, NULL, totalLeftLength, textHeight + 2.0);
  CGPathAddLineToPoint(path, NULL, totalLeftLength - margin, textHeight + 2.0 + arrowSize);
  CGPathAddLineToPoint(path, NULL, totalLeftLength - margin + internalWidth, textHeight + 2.0 + arrowSize);
  CGPathAddLineToPoint(path, NULL, totalLeftLength - 2.0 * margin + internalWidth, textHeight + 2.0);
  CGPathAddLineToPoint(path, NULL, totalLeftLength + internalWidth + totalRightLength, textHeight + 2.0);
  CGPathAddLineToPoint(path, NULL, totalLeftLength + internalWidth + totalRightLength, 0);
  CGPathCloseSubpath(path);

  return path;
}

@end
