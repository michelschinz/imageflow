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

+ (IFTreeLayoutComposite*)layoutCompositeWithElements:(NSSet*)theElements containingView:(IFTreeView*)theContainingView;
{
  return [[[self alloc] initWithElements:theElements containingView:theContainingView] autorelease];
}

-(id)initWithElements:(NSSet*)theElements containingView:(IFTreeView*)theContainingView;
{
  if (![super initWithContainingView:theContainingView])
    return nil;

  elements = [theElements retain];
  NSRect myBounds = NSZeroRect;
  NSEnumerator* elemsEnum = [elements objectEnumerator];
  IFTreeLayoutElement* elem;
  while (elem = [elemsEnum nextObject])
    myBounds = NSUnionRect(myBounds, [elem frame]);
  [self setBounds:myBounds];
  return self;
}

- (void)dealloc;
{
  [elements release];
  elements = nil;
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
  NSEnumerator* elemsEnum = [elements objectEnumerator];
  IFTreeLayoutElement* elem;
  while (elem = [elemsEnum nextObject]) {
    if (NSIntersectsRect([elem frame], rect))
      [elem drawForRect:rect];
  }
}

- (NSSet*)leavesOfKind:(IFTreeLayoutElementKind)kind;
{
  NSMutableSet* leaves = [NSMutableSet set];
  NSEnumerator* elemsEnum = [elements objectEnumerator];
  IFTreeLayoutElement* elem;
  while (elem = [elemsEnum nextObject])
    [leaves unionSet:[elem leavesOfKind:kind]];
  return leaves;
}

- (IFTreeLayoutSingle*)layoutElementForNode:(IFTreeNode*)node kind:(IFTreeLayoutElementKind)kind;
{
  NSEnumerator* elemsEnum = [elements objectEnumerator];
  IFTreeLayoutElement* elem;
  while (elem = [elemsEnum nextObject]) {
    IFTreeLayoutSingle* elemForNode = [elem layoutElementForNode:node kind:kind];
    if (elemForNode != nil)
      return elemForNode;
  }
  return nil;
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  NSEnumerator* elemsEnum = [elements objectEnumerator];
  IFTreeLayoutElement* elem;
  while (elem = [elemsEnum nextObject]) {
    if (NSPointInRect(thePoint, [elem frame]))
      return [elem layoutElementAtPoint:thePoint];
  }
  return nil;
}

- (NSSet*)layoutElementsIntersectingRect:(NSRect)rect kind:(IFTreeLayoutElementKind)kind;
{
  NSMutableSet* result = [NSMutableSet set];
  if (NSIntersectsRect([self frame],rect)) {
    NSEnumerator* elemsEnum = [elements objectEnumerator];
    IFTreeLayoutElement* elem;
    while (elem = [elemsEnum nextObject])
      [result unionSet:[elem layoutElementsIntersectingRect:rect kind:kind]];
  }
  return result;
}

@end
