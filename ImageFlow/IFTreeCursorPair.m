//
//  IFTreeCursorPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeCursorPair.h"
#import "NSAffineTransformIFAdditions.h"

@implementation IFTreeCursorPair

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode path:(IFArrayPath*)newPath;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (IFTree*)tree;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFTreeNode*)node;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFArrayPath*)path;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFTree*)viewLockedTree;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFTreeNode*)viewLockedNode;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFArrayPath*)viewLockedPath;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (BOOL)isViewLocked;
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (NSAffineTransform*)editViewTransform;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSAffineTransform*)viewEditTransform;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
