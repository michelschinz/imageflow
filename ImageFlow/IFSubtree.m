//
//  IFSubtree.m
//  ImageFlow
//
//  Created by Michel Schinz on 01.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFSubtree.h"

#import "IFTreeNodeHole.h"

@implementation IFSubtree

+ (id)subtreeOf:(IFTree*)theBaseTree includingNodes:(NSSet*)theIncludedNodes;
{
  return [[[self alloc] initWithTree:theBaseTree includingNodes:theIncludedNodes] autorelease];
}

- (id)initWithTree:(IFTree*)theBaseTree includingNodes:(NSSet*)theIncludedNodes;
{
  if (![super init])
    return nil;
  baseTree = [theBaseTree retain];
  includedNodes = [theIncludedNodes retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(includedNodes);
  OBJC_RELEASE(baseTree);
  [super dealloc];
}

- (IFTree*)baseTree;
{
  return baseTree;
}

- (IFTreeNode*)root;
{
  IFTreeNode* root = nil;
  NSEnumerator* nodesEnum = [includedNodes objectEnumerator];
  IFTreeNode* node;
  while (node = [nodesEnum nextObject]) {
    if ([includedNodes containsObject:[baseTree childOfNode:node]])
      continue;
    NSAssert(root == nil, @"invalid subtree (more than one root)");
    root = node;
  }
  NSAssert(root != nil, @"invalid subtree (no root)");
  return root;
}

- (NSSet*)includedNodes;
{
  return includedNodes;
}

- (BOOL)containsNode:(IFTreeNode*)node;
{
  return [includedNodes containsObject:node];
}

- (IFTree*)extractTree;
{
  IFTree* tree = [IFTree tree];

  IFTreeNode* root = [self root];
  [tree addNode:root];
  NSMutableSet* nodesToConsider = [NSMutableSet setWithObject:root];

  while ([nodesToConsider count] != 0) {
    IFTreeNode* node = [nodesToConsider anyObject];
    [nodesToConsider removeObject:node];
    NSArray* parents = [baseTree parentsOfNode:node];
    for (int i = 0; i < [parents count]; ++i) {
      IFTreeNode* parent = [parents objectAtIndex:i];
      IFTreeNode* newParent = [includedNodes containsObject:parent] ? parent : [IFTreeNodeHole hole];
      [tree addNode:newParent];
      [tree addEdgeFromNode:newParent toNode:node withIndex:i];
      if (parent == newParent)
        [nodesToConsider addObject:parent];
    }
  }
  return tree;
}

#pragma NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithTree:[decoder decodeObjectForKey:@"baseTree"] includingNodes:[decoder decodeObjectForKey:@"includedNodes"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:baseTree forKey:@"baseTree"];
  [encoder encodeObject:includedNodes forKey:@"includedNodes"];
}

@end
