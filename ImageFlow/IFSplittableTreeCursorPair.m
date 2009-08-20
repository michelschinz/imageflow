//
//  IFSplittableTreeCursorPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFSplittableTreeCursorPair.h"

@interface IFSplittableTreeCursorPair ()
@property(retain) IFTree* tree;
@property(retain) IFTreeNode* node;
@property unsigned index;
@property(retain) IFTree* viewLockedTree;
@property(retain) IFTreeNode* viewLockedNode;
@property unsigned viewLockedIndex;
@property(retain) NSAffineTransform* editViewTransform;
@property(retain) NSAffineTransform* viewEditTransform;
- (void)updateTransforms;
@end

@implementation IFSplittableTreeCursorPair

+ (IFSplittableTreeCursorPair*)splittableTreeCursorPair;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(viewEditTransform);
  OBJC_RELEASE(editViewTransform);
  OBJC_RELEASE(viewLockedNode);
  OBJC_RELEASE(viewLockedTree);
  OBJC_RELEASE(node);
  OBJC_RELEASE(tree);
  [super dealloc];
}

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode index:(unsigned)newIndex;
{
  self.tree = newTree;
  self.node = newNode;
  self.index = newIndex;
  if (!isViewLocked) {
    self.viewLockedTree = newTree;
    self.viewLockedNode = newNode;
    self.viewLockedIndex = newIndex;
  }
  [self updateTransforms];
}

@synthesize tree, node, index;
@synthesize viewLockedTree, viewLockedNode, viewLockedIndex;
@synthesize isViewLocked;

- (void)setIsViewLocked:(BOOL)newIsViewLocked;
{
  if (newIsViewLocked == isViewLocked)
    return;

  isViewLocked = newIsViewLocked;
  if (!isViewLocked) {
    self.viewLockedTree = tree;
    self.viewLockedNode = node;
    self.viewLockedIndex = index;
    [self updateTransforms];
  }
}

@synthesize editViewTransform, viewEditTransform;

// MARK: -
// MARK: PRIVATE

static NSAffineTransform* nodeToNodeTransform(IFTree* tree, IFTreeNode* fromNode, IFTreeNode* toNode) {
  NSAffineTransform* transform = [NSAffineTransform transform];
  
  IFTreeNode* child = nil;
  for (IFTreeNode* node = fromNode; node != toNode; node = [tree childOfNode:node]) {
    child = [tree childOfNode:node];
    if (child == nil)
      return nil; // no path from fromNode to toNode
    [transform appendTransform:[child transformForParentAtIndex:[[tree parentsOfNode:child] indexOfObject:node]]];
  }
  return transform;
}

- (void)updateTransforms;
{
  if (tree != viewLockedTree) {
    self.editViewTransform = nil;
    self.viewEditTransform = nil;
    return;
  }

  self.editViewTransform = nodeToNodeTransform(tree, node, viewLockedNode);
  if (editViewTransform != nil) {
    // there is a path from the edited to the viewed node
    self.viewEditTransform = [[editViewTransform copy] autorelease];
    [viewEditTransform invert];
  } else {
    self.viewEditTransform = nodeToNodeTransform(tree, viewLockedNode, node);
    if (viewEditTransform != nil) {
      // there is a path from the viewed node to the edited node
      self.editViewTransform = [[viewEditTransform copy] autorelease];
      [editViewTransform invert];
    } else
      ; // nothing to do: both transforms are already nil
  }
}

@end
