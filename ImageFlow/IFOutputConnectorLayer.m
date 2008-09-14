//
//  IFOutputConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFOutputConnectorLayer.h"

@implementation IFOutputConnectorLayer

+ (id)outputConnectorLayerWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initForNode:theNode layoutParameters:theLayoutParameters] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(label);
  [super dealloc];
}

@synthesize label;

- (void)setLabel:(NSString*)newLabel;
{
  if (newLabel == label)
    return;
  if (![newLabel isEqualToString:label])
    [self setNeedsDisplay];
  [label release];
  label = [newLabel retain];
}

@synthesize leftReach;

- (void)setLeftReach:(float)newLeftReach;
{
  if (newLeftReach != leftReach)
    [self.superlayer setNeedsLayout];
  leftReach = newLeftReach;
}

@synthesize rightReach;

- (void)setRightReach:(float)newRightReach;
{
  if (newRightReach != rightReach)
    [self.superlayer setNeedsLayout];
  rightReach = newRightReach;
}

- (CGSize)preferredFrameSize;
{
  NSBezierPath* outline = [NSBezierPath bezierPath];
  
  const float margin = layoutParameters.nodeInternalMargin;
  const float arrowSize = layoutParameters.connectorArrowSize;
  const float internalWidth = layoutParameters.columnWidth - 2.0 * margin;
  const float textHeight = layoutParameters.labelFontHeight;
  
  float totalLeftLength = arrowSize + margin + leftReach;
  float totalRightLength = arrowSize + margin + rightReach;
  
  // Build the path in a clockwise direction, starting from the bottom-left corner (put at the origin)
  [outline moveToPoint:NSZeroPoint];
  [outline relativeLineToPoint:NSMakePoint(0, textHeight + 2.0)];
  [outline relativeLineToPoint:NSMakePoint(totalLeftLength, 0)];
  
  [outline relativeLineToPoint:NSMakePoint(-arrowSize, arrowSize)];
  [outline relativeLineToPoint:NSMakePoint(internalWidth, 0)];
  [outline relativeLineToPoint:NSMakePoint(-arrowSize, -arrowSize)];
  
  [outline relativeLineToPoint:NSMakePoint(totalRightLength, 0)];
  [outline relativeLineToPoint:NSMakePoint(0, -(textHeight + 2.0))];
  
  [outline closePath];
  
  self.outlinePath = outline;
  
  return NSSizeToCGSize(outlinePath.bounds.size);
}


- (void)drawInCurrentNSGraphicsContext;
{
  [layoutParameters.connectorColor set];
  [self.outlinePath fill];
  
  if (label != nil) {
    NSMutableParagraphStyle* parStyle = [NSMutableParagraphStyle new];
    [parStyle setAlignment:NSCenterTextAlignment];
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                parStyle, NSParagraphStyleAttributeName,
                                layoutParameters.labelFont, NSFontAttributeName,
                                layoutParameters.connectorLabelColor, NSForegroundColorAttributeName,
                                nil];
    NSAttributedString* attributedLabel = [[NSMutableAttributedString alloc] initWithString:label attributes:attributes];
    float textHeight = layoutParameters.labelFontHeight;
    [attributedLabel drawWithRect:NSMakeRect(leftReach, 2.0, layoutParameters.columnWidth, textHeight) options:0];
  }
}

@end
