//
//  IFTreeLayoutInputConnector.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutInputConnector.h"
#import "IFTreeView.h"

@interface IFTreeLayoutInputConnector (Private)
- (void)computeOutlinePath;
@end

@implementation IFTreeLayoutInputConnector

+ (id)layoutConnectorWithNode:(IFTreeNode*)theNode containingView:(IFTreeView*)theContainingView;
{
  return [[[self alloc] initWithNode:theNode containingView:theContainingView] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFTreeView*)theContainingView;
{
  if (![super initWithNode:theNode containingView:theContainingView])
    return nil;
  [self computeOutlinePath];
  return self;
}

- (IFTreeLayoutElementKind)kind;
{
  return IFTreeLayoutElementKindInputConnector;
}

- (void)drawForLocalRect:(NSRect)rect;
{
  [[[containingView layoutParameters] connectorColor] set];
  [[self outlinePath] fill];
}

@end

@implementation IFTreeLayoutInputConnector (Private)

- (void)computeOutlinePath;
{
  NSBezierPath* outline = [NSBezierPath bezierPath];
  
  IFTreeLayoutParameters* layoutParams = [containingView layoutParameters];
  const float margin = [layoutParams nodeInternalMargin];
  const float arrowSize = [layoutParams connectorArrowSize];
  const float internalWidth = [layoutParams columnWidth] - 2.0 * margin;
  
  // Build the path in a clockwise direction, starting from the top-left part of the "arrow"
  [outline moveToPoint:NSMakePoint(margin,0)];
  [outline relativeLineToPoint:NSMakePoint(internalWidth,0)];
  [outline relativeLineToPoint:NSMakePoint(-arrowSize,-arrowSize)];
  [outline relativeLineToPoint:NSMakePoint(-(internalWidth - 2.0 * arrowSize),0)];
  [outline closePath];
  
  [self setOutlinePath:outline];  
}

@end
