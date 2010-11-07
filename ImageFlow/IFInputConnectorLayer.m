//
//  IFInputConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFInputConnectorLayer.h"
#import "IFLayoutParameters.h"

@interface IFInputConnectorLayer ()
- (void)updatePath;
@end

@implementation IFInputConnectorLayer

- (IFConnectorKind)kind;
{
  return IFConnectorKindInput;
}

@synthesize width;

- (void)setWidth:(float)newWidth;
{
  if (newWidth == width)
    return;
  width = newWidth;
  [self updatePath];
}

// MARK: -
// MARK: PRIVATE

- (void)updatePath;
{
  const float margin = [IFLayoutParameters nodeInternalMargin];
  const float arrowSize = [IFLayoutParameters connectorArrowSize];

  CGMutablePathRef newPath = CGPathCreateMutable();
  CGPathMoveToPoint(newPath, NULL, margin, 0);
  CGPathAddLineToPoint(newPath, NULL, 0, arrowSize);
  CGPathAddLineToPoint(newPath, NULL, width, arrowSize);
  CGPathAddLineToPoint(newPath, NULL, width - margin, 0);
  CGPathCloseSubpath(newPath);

  self.path = newPath;
}

@end
