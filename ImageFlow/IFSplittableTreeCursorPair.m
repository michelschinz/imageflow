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
@property(retain) IFArrayPath* path;
@property(retain) IFTree* viewLockedTree;
@property(retain) IFTreeNode* viewLockedNode;
@property(retain) IFArrayPath* viewLockedPath;
@property(retain) NSAffineTransform* editViewTransform;
@property(retain) NSAffineTransform* viewEditTransform;
- (void)updateTransforms;
@end

@implementation IFSplittableTreeCursorPair

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
  static NSSet* manualKeys = nil;
  if (manualKeys == nil)
    manualKeys = [[NSSet setWithObjects:@"tree", @"node", @"path", @"viewLockedTree", @"viewLockedNode", @"viewLockedPath", nil] retain];
  return ![manualKeys containsObject:key];
}

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

- (void)setTree:(IFTree*)newTree node:(IFTreeNode*)newNode path:(IFArrayPath*)newPath;
{
  [self willChangeValueForKey:@"tree"];
  [self willChangeValueForKey:@"node"];
  [self willChangeValueForKey:@"path"];
  self.tree = newTree;
  self.node = newNode;
  self.path = newPath;
  [self didChangeValueForKey:@"path"];
  [self didChangeValueForKey:@"node"];
  [self didChangeValueForKey:@"tree"];
  if (!isViewLocked) {
    [self willChangeValueForKey:@"viewLockedTree"];
    [self willChangeValueForKey:@"viewLockedNode"];
    [self willChangeValueForKey:@"viewLockedPath"];
    self.viewLockedTree = newTree;
    self.viewLockedNode = newNode;
    self.viewLockedPath = newPath;
    [self didChangeValueForKey:@"viewLockedPath"];
    [self didChangeValueForKey:@"viewLockedNode"];
    [self didChangeValueForKey:@"viewLockedTree"];
  }
  [self updateTransforms];
}

@synthesize tree, node, path;
@synthesize viewLockedTree, viewLockedNode, viewLockedPath;
@synthesize isViewLocked;

- (void)setIsViewLocked:(BOOL)newIsViewLocked;
{
  if (newIsViewLocked == isViewLocked)
    return;

  isViewLocked = newIsViewLocked;
  if (!isViewLocked) {
    self.viewLockedTree = tree;
    self.viewLockedNode = node;
    self.viewLockedPath = path;
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
