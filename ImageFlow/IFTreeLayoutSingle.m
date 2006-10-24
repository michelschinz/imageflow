//
//  IFTreeLayoutSingle.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.07.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutSingle.h"
#import "IFTreeLayoutNode.h"
#import "IFTreeLayoutGhost.h"

@implementation IFTreeLayoutSingle

+ (id)layoutSingleWithNode:(IFTreeNode*)theNode containingView:(IFTreeView*)theContainingView;
{
  IFTreeLayoutSingle* layoutElem = [theNode isGhost]
  ? [[IFTreeLayoutGhost alloc] initWithNode:theNode containingView:theContainingView]
  : [[IFTreeLayoutNode alloc] initWithNode:theNode containingView:theContainingView];
  return [layoutElem autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFTreeView*)theContainingView;
{
  if (![super initWithContainingView:theContainingView]) return nil;
  node = theNode;
  return self;
}

- (void)dealloc;
{
  [outlinePath release];
  outlinePath = nil;
  [super dealloc];
}

- (IFTreeNode*)node;
{
  return node;
}

- (void)setOutlinePath:(NSBezierPath*)newOutlinePath;
{
  if (newOutlinePath == outlinePath)
    return;
  [outlinePath release];
  outlinePath = [newOutlinePath retain];
  
  [self setBounds:[outlinePath bounds]];
}

- (NSBezierPath*)outlinePath;
{
  return outlinePath;
}

- (IFTreeLayoutElementKind)kind;
{
  [self doesNotRecognizeSelector:_cmd];
  return -1;
}

- (NSSet*)leavesOfKind:(IFTreeLayoutElementKind)kind;
{
  return (kind == [self kind]) ? [NSSet setWithObject:self] : [NSSet set];
}

- (IFTreeLayoutSingle*)layoutElementForNode:(IFTreeNode*)theNode kind:(IFTreeLayoutElementKind)kind;
{
  return (node == theNode) && (kind == [self kind]) ? self : nil;
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  NSPoint offset = [self translation];
  NSPoint localPoint = NSMakePoint(thePoint.x - offset.x, thePoint.y - offset.y);
  return NSPointInRect(localPoint, [self bounds]) && [outlinePath containsPoint:localPoint] ? self : nil;
}

- (NSSet*)layoutElementsIntersectingRect:(NSRect)rect kind:(IFTreeLayoutElementKind)kind;
{
  if (kind == [self kind] && NSIntersectsRect([self frame],rect))
    return [NSSet setWithObject:self];
  else
    return [NSSet set];
}

- (void)collectLayoutElementsForNodes:(NSSet*)nodes kind:(IFTreeLayoutElementKind)kind inSet:(NSMutableSet*)resultSet;
{
  if ([nodes containsObject:node] && kind == [self kind])
    [resultSet addObject:self];
}

@end
