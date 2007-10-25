//
//  IFTree.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTree.h"

// HACK (temporary)
@interface IFTreeNode (Private)
- (NSArray*)parents;
- (void)insertObject:(IFTreeNode*)parent inParentsAtIndex:(unsigned int)index;
- (void)removeObjectFromParentsAtIndex:(unsigned int)index;
- (void)replaceObjectInParentsAtIndex:(unsigned int)index withObject:(IFTreeNode*)newParent;
- (IFTreeNode*)child;
@end

@interface IFTree (Private)
- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
@end

@implementation IFTree

+ (id)tree;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  if (![super init])
    return nil;
  return self;
}

- (void)dealloc;
{
  [super dealloc];
}

- (IFGraph*)graphOfNode:(IFTreeNode*)node;
{
  IFGraph* grph = [IFGraph graph];
  
  // Phase 1: collect all tree nodes and create corresponding graph nodes.
  NSMutableDictionary* treeNodeToGraphNode = createMutableDictionaryWithRetainedKeys();
  NSMutableSet* nodesToVisit = [NSMutableSet setWithObject:node];
  while ([nodesToVisit count] > 0) {
    IFTreeNode* treeNode = [nodesToVisit anyObject];
    if (![treeNode isAlias]) {
      IFGraphNode* graphNode = [IFGraphNode graphNodeWithTypes:[treeNode potentialTypes] data:treeNode];
      CFDictionarySetValue((CFMutableDictionaryRef)treeNodeToGraphNode,treeNode,graphNode);
      [grph addNode:graphNode];
    }
    [nodesToVisit removeObject:treeNode];
    [nodesToVisit addObjectsFromArray:[self parentsOfNode:treeNode]];
  }
  
  // Phase 2: set predecessors for graph nodes.
  NSEnumerator* nodeEnum = [treeNodeToGraphNode keyEnumerator];
  IFTreeNode* treeNode;
  while (treeNode = [nodeEnum nextObject]) {
    NSArray* nodeParents = [self parentsOfNode:treeNode];
    IFGraphNode* graphNode = [treeNodeToGraphNode objectForKey:treeNode];
    for (int i = 0; i < [nodeParents count]; ++i)
      [graphNode addPredecessor:[treeNodeToGraphNode objectForKey:[[nodeParents objectAtIndex:i] original]]];
  }
  return grph;
}

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
{
  return [node parents];
}

- (IFTreeNode*)childOfNode:(IFTreeNode*)node;
{
  return [node child];
}

- (NSArray*)siblingsOfNode:(IFTreeNode*)node;
{
  return [self parentsOfNode:[self childOfNode:node]];
}

- (NSArray*)dfsAncestorsOfNode:(IFTreeNode*)node;
{
  NSMutableArray* result = [NSMutableArray array];
  [self dfsCollectAncestorsOfNode:node inArray:result];
  return result;
}

- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
{
  return [[self parentsOfNode:node] count];
}

- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;
{
  if (![node isGhost])
    return NO;
  for (int i = 0; i < [self parentsCountOfNode:node]; ++i)
    if (![self isGhostSubtreeRoot:[[self parentsOfNode:node] objectAtIndex:i]])
      return NO;
  return YES;
}

- (void)insertObject:(IFTreeNode*)newParent inParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index;
{
  [node insertObject:newParent inParentsAtIndex:index];
}

- (void)replaceObjectInParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index withObject:(IFTreeNode*)newParent;
{
  [node replaceObjectInParentsAtIndex:index withObject:newParent];
}

- (void)removeObjectFromParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index;
{
  [node removeObjectFromParentsAtIndex:index];
}

@end

@implementation IFTree (Private)

- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
{
  [[self do] dfsCollectAncestorsOfNode:[[self parentsOfNode:node] each] inArray:accumulator];
  [accumulator addObject:node];
}

@end