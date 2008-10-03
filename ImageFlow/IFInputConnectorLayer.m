//
//  IFInputConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFInputConnectorLayer.h"
#import "IFLayoutParameters.h"

@implementation IFInputConnectorLayer

- (CGPathRef)createOutlinePath;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float arrowSize = layoutParameters.connectorArrowSize;
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, arrowSize, 0);
  CGPathAddLineToPoint(path, NULL, 0, arrowSize);
  CGPathAddLineToPoint(path, NULL, layoutParameters.columnWidth - 2.0 * layoutParameters.nodeInternalMargin, arrowSize);
  CGPathAddLineToPoint(path, NULL, layoutParameters.columnWidth - 2.0 * layoutParameters.nodeInternalMargin - arrowSize, 0);
  CGPathCloseSubpath(path);
  
  return path;
}

@end
