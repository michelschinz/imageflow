//
//  IFTreeLayoutOutputConnector.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutOutputConnector.h"
#import "IFNodesView.h"

@interface IFTreeLayoutOutputConnector (Private)
- (void)computeOutlinePath;
@end

@implementation IFTreeLayoutOutputConnector

+ (id)layoutConnectorWithNode:(IFTreeNode*)theNode
               containingView:(IFNodesView*)theContainingView
                          tag:(NSString*)theTag
                    leftReach:(float)theLeftReach
                   rightReach:(float)theRightReach;
{
  return [[[self alloc] initWithNode:theNode
                      containingView:(IFNodesView*)theContainingView
                                 tag:theTag
                           leftReach:theLeftReach
                          rightReach:theRightReach] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode
    containingView:(IFNodesView*)theContainingView
               tag:(NSString*)theTag
         leftReach:(float)theLeftReach
        rightReach:(float)theRightReach;
{
  if (![super initWithNode:theNode containingView:theContainingView])
    return nil;
  
  NSMutableParagraphStyle* parStyle = [NSMutableParagraphStyle new];
  [parStyle setAlignment:NSCenterTextAlignment];
  tag = [[NSMutableAttributedString alloc] initWithString:theTag
                                               attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 parStyle, NSParagraphStyleAttributeName,
                                                 [[theContainingView layoutParameters] labelFont], NSFontAttributeName,
                                                 [[theContainingView layoutParameters] connectorLabelColor], NSForegroundColorAttributeName,
                                                 nil]];
  leftReach = theLeftReach;
  rightReach = theRightReach;
  [self computeOutlinePath];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(tag);
  [super dealloc];
}

- (IFTreeLayoutElementKind)kind;
{
  return IFTreeLayoutElementKindOutputConnector;
}

- (void)drawForLocalRect:(NSRect)rect;
{
  IFTreeLayoutParameters* layoutParams = [containingView layoutParameters];
  [layoutParams.connectorColor set];
  [[self outlinePath] fill];

  if (tag != nil) {
    float textHeight = layoutParams.labelFontHeight;
    [tag drawWithRect:NSMakeRect(0,-(textHeight + 1.0),layoutParams.columnWidth,textHeight) options:0];
  }
}

@end

@implementation IFTreeLayoutOutputConnector (Private)

- (void)computeOutlinePath;
{
  // The outline path is constructed in such a way that the connector is correctly placed under a node whose bottom-left corner lies at the origin. For that reason, most of the points of the outline path have negative Y components.
  NSBezierPath* outline = [NSBezierPath bezierPath];

  IFTreeLayoutParameters* layoutParams = [containingView layoutParameters];
  const float margin = layoutParams.nodeInternalMargin;
  const float arrowSize = layoutParams.connectorArrowSize;
  const float columnWidth = layoutParams.columnWidth;
  const float internalWidth = columnWidth - 2.0 * margin;
  const float textHeight = layoutParams.labelFontHeight;

  // Build the path in a clockwise direction, starting from the top-left part of the top arrow
  [outline moveToPoint:NSMakePoint(margin,0)];
  [outline relativeLineToPoint:NSMakePoint(internalWidth,0)];
  [outline relativeLineToPoint:NSMakePoint(-arrowSize,-arrowSize)];

  float totalRightLength = arrowSize + margin + rightReach;
  [outline relativeLineToPoint:NSMakePoint(totalRightLength, 0)];
  [outline relativeLineToPoint:NSMakePoint(0,-(textHeight + 2.0))];
  [outline relativeLineToPoint:NSMakePoint(-totalRightLength, 0)];

  [outline relativeLineToPoint:NSMakePoint(-(internalWidth - 2.0 * arrowSize), 0)];

  float totalLeftLength = arrowSize + margin + leftReach;
  [outline relativeLineToPoint:NSMakePoint(-totalLeftLength, 0)];
  [outline relativeLineToPoint:NSMakePoint(0,textHeight + 2.0)];
  [outline relativeLineToPoint:NSMakePoint(totalLeftLength, 0)];

  [outline closePath];
  
  [self setOutlinePath:outline];  
}

@end
