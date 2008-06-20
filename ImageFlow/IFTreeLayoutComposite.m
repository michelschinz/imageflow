//
//  IFTreeLayoutComposite.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutComposite.h"


@implementation IFTreeLayoutComposite

+ (IFTreeLayoutComposite*)layoutComposite;
{
  return [self layoutCompositeWithElements:[NSSet set] containingView:nil];
}

+ (IFTreeLayoutComposite*)layoutCompositeWithElements:(NSSet*)theElements containingView:(IFNodesView*)theContainingView;
{
  return [[[self alloc] initWithElements:theElements containingView:theContainingView] autorelease];
}

-(id)initWithElements:(NSSet*)theElements containingView:(IFNodesView*)theContainingView;
{
  if (![super initWithContainingView:theContainingView])
    return nil;

  elements = [theElements retain];
  NSRect myBounds = NSZeroRect;
  for (IFTreeLayoutElement* elem in elements)
    myBounds = NSUnionRect(myBounds, [elem frame]);
  [self setBounds:myBounds];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(elements);
  [super dealloc];
}

- (void)translateBy:(NSPoint)thePoint;
{
  NSEnumerator* elemsEnum = [elements objectEnumerator];
  IFTreeLayoutElement* elem;
  while (elem = [elemsEnum nextObject])
    [elem translateBy:thePoint];
  [super translateBy:thePoint];
}

- (void)drawForRect:(NSRect)rect;
{
  for (IFTreeLayoutElement* elem in elements) {
    if (NSIntersectsRect([elem frame], rect))
      [elem drawForRect:rect];
  }
}

- (NSSet*)leavesOfKind:(IFTreeLayoutElementKind)kind;
{
  NSMutableSet* leaves = [NSMutableSet set];
  for (IFTreeLayoutElement* elem in elements)
    [leaves unionSet:[elem leavesOfKind:kind]];
  return leaves;
}

- (IFTreeLayoutSingle*)layoutElementForNode:(IFTreeNode*)node kind:(IFTreeLayoutElementKind)kind;
{
  for (IFTreeLayoutElement* elem in elements) {
    IFTreeLayoutSingle* elemForNode = [elem layoutElementForNode:node kind:kind];
    if (elemForNode != nil)
      return elemForNode;
  }
  return nil;
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  for (IFTreeLayoutElement* elem in elements) {
    if (NSPointInRect(thePoint, [elem frame]))
      return [elem layoutElementAtPoint:thePoint];
  }
  return nil;
}

- (NSSet*)layoutElementsIntersectingRect:(NSRect)rect kind:(IFTreeLayoutElementKind)kind;
{
  NSMutableSet* result = [NSMutableSet set];
  if (NSIntersectsRect([self frame],rect)) {
    for (IFTreeLayoutElement* elem in elements)
      [result unionSet:[elem layoutElementsIntersectingRect:rect kind:kind]];
  }
  return result;
}

- (void)collectLayoutElementsForNodes:(NSSet*)nodes kind:(IFTreeLayoutElementKind)kind inSet:(NSMutableSet*)resultSet;
{
  [[elements do] collectLayoutElementsForNodes:nodes kind:kind inSet:resultSet];
}

@end
