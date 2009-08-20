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
@property unsigned index;
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

+ (NSSet*)keyPathsForValuesAffectingViewLockedIndex;
{
  return [NSSet setWithObject:@"index"];
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

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode index:(unsigned)newIndex;
{
  self.tree = newTree;
  self.node = newNode;
  self.index = newIndex;
}

@synthesize tree, node, index;

- (IFTree*)viewLockedTree;
{
  return tree;
}

- (IFTreeNode*)viewLockedNode;
{
  return node;
}

- (unsigned)viewLockedIndex;
{
  return index;
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
