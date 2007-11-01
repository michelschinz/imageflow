//
//  IFSubtree.m
//  ImageFlow
//
//  Created by Michel Schinz on 01.11.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFSubtree.h"

@interface IFSubtree (Private)
- (void)collectSortedParentsOfInputNodesIn:(NSMutableArray*)result startingAt:(IFTreeNode*)root;
@end

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

- (unsigned)inputArity;
{
  return [[self sortedParentsOfInputNodes] count];
}

- (NSArray*)sortedParentsOfInputNodes;
{
  NSMutableArray* inputNodes = [NSMutableArray array];
  [self collectSortedParentsOfInputNodesIn:inputNodes startingAt:[self root]];
  return inputNodes;
}

@end

@implementation IFSubtree (Private)

- (void)collectSortedParentsOfInputNodesIn:(NSMutableArray*)result startingAt:(IFTreeNode*)root;
{
  NSArray* parents = [baseTree parentsOfNode:root];
  for (int i = 0; i < [parents count]; ++i) {
    IFTreeNode* parent = [parents objectAtIndex:i];
    if ([includedNodes containsObject:parent])
      [self collectSortedParentsOfInputNodesIn:result startingAt:parent];
    else
      [result addObject:parent];
  }
}

@end
