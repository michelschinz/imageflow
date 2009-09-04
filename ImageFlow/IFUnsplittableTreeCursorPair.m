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
@property(retain) IFArrayPath* path;
@end

@implementation IFUnsplittableTreeCursorPair

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
  static NSSet* manualKeys = nil;
  if (manualKeys == nil)
    manualKeys = [[NSSet setWithObjects:@"tree", @"node", @"path", nil] retain];
  return ![manualKeys containsObject:key];
}

+ (NSSet*)keyPathsForValuesAffectingViewLockedTree;
{
  return [NSSet setWithObject:@"tree"];
}

+ (NSSet*)keyPathsForValuesAffectingViewLockedNode;
{
  return [NSSet setWithObject:@"node"];
}

+ (NSSet*)keyPathsForValuesAffectingViewLockedPath;
{
  return [NSSet setWithObject:@"path"];
}

+ (IFUnsplittableTreeCursorPair*)unsplittableTreeCursorPair;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(path);
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
}

@synthesize tree, node, path;

- (IFTree*)viewLockedTree;
{
  return tree;
}

- (IFTreeNode*)viewLockedNode;
{
  return node;
}

- (IFArrayPath*)viewLockedPath;
{
  return path;
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
