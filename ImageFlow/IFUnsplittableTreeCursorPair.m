//
//  IFUnsplittableTreeCursorPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFUnsplittableTreeCursorPair.h"

@interface IFTreeCursorPair ()
@property(retain) IFTree* tree;
@property(retain) IFTreeNode* node;
@end

@implementation IFUnsplittableTreeCursorPair

+ (NSSet*)keyPathsForValuesAffectingViewLockedTree;
{
  return [NSSet setWithObject:@"tree"];
}

+ (NSSet*)keyPathsForValuesAffectingViewLockedNode;
{
  return [NSSet setWithObject:@"node"];
}

+ (IFUnsplittableTreeCursorPair*)unsplittableTreeCursorPair;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(node);
  OBJC_RELEASE(tree);
  [super dealloc];
}

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode;
{
  self.tree = newTree;
  self.node = newNode;
}

@synthesize tree, node;

- (IFTree*)viewLockedTree;
{
  return tree;
}

- (IFTreeNode*)viewLockedNode;
{
  return node;
}

- (BOOL)isViewLocked;
{
  return NO;
}

- (NSAffineTransform*)editViewTransform;
{
  return [NSAffineTransform transform];
}

- (NSAffineTransform*)viewEditTransform;
{
  return [NSAffineTransform transform];
}

@end
