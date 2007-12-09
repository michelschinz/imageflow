//
//  IFTreeCursorPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeCursorPair.h"
#import "NSAffineTransformIFAdditions.h"

@interface IFTreeCursorPair (Private)
- (void)updateTransforms;
@end

@implementation IFTreeCursorPair

+ (void)initialize;
{
  if (self != [IFTreeCursorPair class])
    return; // avoid repeated initialisation
  
  [self setKeys:[NSArray arrayWithObject:@"isViewLocked"] triggerChangeNotificationsForDependentKey:@"viewLockedNode"];
}

+ (IFTreeCursorPair*)treeCursorPairWithTree:(IFTree*)theTree editMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;
{
  return [[[self alloc] initWithTree:theTree editMark:theEditMark viewMark:theViewMark] autorelease];
}

- (IFTreeCursorPair*)initWithTree:(IFTree*)theTree editMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;
{
  if (![super init])
    return nil;
  tree = [theTree retain];
  editMark = [theEditMark retain];
  viewMark = [theViewMark retain];
  editViewTransform = [[NSAffineTransform transform] retain];
  viewEditTransform = [[NSAffineTransform transform] retain];
  
  if ([editMark node] != [viewMark node])
    [self updateTransforms];

  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(viewEditTransform);
  OBJC_RELEASE(editViewTransform);
  OBJC_RELEASE(viewMark);
  OBJC_RELEASE(editMark);
  OBJC_RELEASE(tree);
  [super dealloc];
}

- (IFTreeMark*)viewMark;
{
  return viewMark;
}

- (IFTreeMark*)editMark;
{
  return editMark;
}

- (void)moveToNode:(IFTreeNode*)newNode;
{
  [editMark setNode:newNode];
  if (isViewLocked)
    [self updateTransforms];
  else
    [viewMark setNode:newNode];
}

- (void)setIsViewLocked:(BOOL)newValue;
{
  isViewLocked = newValue;
  if (!isViewLocked) {
    [viewMark setLikeMark:editMark];
    [editViewTransform setToIdentity];
    [viewEditTransform setToIdentity];
  } else
    NSAssert([viewMark node] == [editMark node], @"internal error");
}

- (BOOL)isViewLocked;
{
  return isViewLocked;
}

- (IFTreeNode*)viewLockedNode;
{
  return isViewLocked ? [viewMark node] : nil;
}

- (NSAffineTransform*)editViewTransform;
{
  return editViewTransform;
}

- (NSAffineTransform*)viewEditTransform;
{
  return viewEditTransform;
}

@end

@implementation IFTreeCursorPair (Private)

- (void)updateTransforms;
{
  [editViewTransform setToIdentity];
  
  IFTreeNode* nodeToEdit = [editMark node];
  IFTreeNode* nodeToView = [viewMark node];
  
  NSAssert(nodeToEdit != nil && nodeToView != nil, @"internal error");
  for (IFTreeNode* node = nodeToEdit; node != nodeToView; node = [tree childOfNode:node]) {
    IFTreeNode* child = [tree childOfNode:node];
    [editViewTransform appendTransform:[child transformForParentAtIndex:[[tree parentsOfNode:child] indexOfObject:node]]];
  }

  [viewEditTransform setTransformStruct:[editViewTransform transformStruct]];
  [viewEditTransform invert];
}

@end
