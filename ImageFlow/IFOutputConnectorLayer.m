//
//  IFOutputConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFOutputConnectorLayer.h"
#import "IFLayoutParameters.h"

@interface IFOutputConnectorLayer ()
- (void)updatePath;
@end

@implementation IFOutputConnectorLayer

- (id)initForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  if (![super initForNode:theNode kind:theKind])
    return nil;
  
  labelLayer = [CATextLayer layer];
  labelLayer.anchorPoint = CGPointZero;
  labelLayer.font = [IFLayoutParameters labelFont];
  labelLayer.fontSize = [IFLayoutParameters labelFont].pointSize;
  labelLayer.foregroundColor = [IFLayoutParameters connectorLabelColor];
  labelLayer.alignmentMode = kCAAlignmentCenter;
  labelLayer.truncationMode = kCATruncationMiddle;
  [self addSublayer:labelLayer];
  
  return self;
}

- (IFConnectorKind)kind;
{
  return IFConnectorKindOutput;
}

- (NSString*)label;
{
  return labelLayer.string;
}

- (void)setLabel:(NSString*)newLabel;
{
  labelLayer.string = newLabel;
}

@synthesize width;

- (void)setWidth:(float)newWidth;
{
  if (newWidth == width)
    return;
  width = newWidth;
  [self updatePath];
}

@synthesize leftReach;

- (void)setLeftReach:(float)newLeftReach;
{
  if (newLeftReach == leftReach)
    return;
  leftReach = newLeftReach;
  [self updatePath];
}

@synthesize rightReach;

- (void)setRightReach:(float)newRightReach;
{
  if (newRightReach == rightReach)
    return;
  rightReach = newRightReach;
  [self updatePath];
}

- (void)layoutSublayers;
{
  labelLayer.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + 1.0, CGRectGetWidth(self.frame), [IFLayoutParameters labelFontHeight]);
}

// MARK: -
// MARK: PRIVATE

- (void)updatePath;
{
  const float margin = [IFLayoutParameters nodeInternalMargin];
  const float arrowSize = [IFLayoutParameters connectorArrowSize];
  const float internalWidth = width - (leftReach + rightReach + 2.0 * margin);
  const float textHeight = [labelLayer preferredFrameSize].height;
  
  float totalLeftLength = 2.0 * margin + leftReach;
  float totalRightLength = 2.0 * margin + rightReach;
  
  // Build the path in a clockwise direction, starting from the bottom-left corner (put at the origin)
  CGMutablePathRef newPath = CGPathCreateMutable();
  CGPathMoveToPoint(newPath, NULL, 0, 0);
  CGPathAddLineToPoint(newPath, NULL, 0, textHeight + 2.0);
  CGPathAddLineToPoint(newPath, NULL, totalLeftLength, textHeight + 2.0);
  CGPathAddLineToPoint(newPath, NULL, totalLeftLength - margin, textHeight + 2.0 + arrowSize);
  CGPathAddLineToPoint(newPath, NULL, totalLeftLength - margin + internalWidth, textHeight + 2.0 + arrowSize);
  CGPathAddLineToPoint(newPath, NULL, totalLeftLength - 2.0 * margin + internalWidth, textHeight + 2.0);
  CGPathAddLineToPoint(newPath, NULL, totalLeftLength + internalWidth + totalRightLength, textHeight + 2.0);
  CGPathAddLineToPoint(newPath, NULL, totalLeftLength + internalWidth + totalRightLength, 0);
  CGPathCloseSubpath(newPath);

  self.path = newPath;
  [self setNeedsLayout];
}

@end
