//
//  IFTreeCursorPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeCursorPair.h"


@implementation IFTreeCursorPair

+ (id)treeCursorPairWithEditMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;
{
  return [[[self alloc] initWithEditMark:theEditMark viewMark:theViewMark] autorelease];
}

- (id)initWithEditMark:(IFTreeMark*)theEditMark viewMark:(IFTreeMark*)theViewMark;
{
  if (![super init])
    return nil;
  editMark = [theEditMark retain];
  viewMark = [theViewMark retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(viewMark);
  OBJC_RELEASE(editMark);
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
  if (!isViewLocked)
    [viewMark setNode:newNode];
}

- (void)setIsViewLocked:(BOOL)newValue;
{
  isViewLocked = newValue;
}

- (BOOL)isViewLocked;
{
  return isViewLocked;
}

@end
