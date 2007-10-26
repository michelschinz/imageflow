//
//  IFTree.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTree.h"
#import "IFTreeEdge.h"
#import "IFTypeChecker.h"

@interface IFTree (Private)
- (NSArray*)serialiseSortedNodes:(NSArray*)sortedNodes;
- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
@end

@implementation IFTree

+ (id)tree;
{
  return [[[self alloc] init] autorelease];
}

- (id)initWithGraph:(IFOrientedGraph*)theGraph;
{
  if (![super init])
    return nil;
  graph = [theGraph retain];
  return self;
}

- (id)init;
{
  return [self initWithGraph:[IFOrientedGraph graph]];
}

- (void)dealloc;
{
  OBJC_RELEASE(graph);
  [super dealloc];
}

- (IFTree*)clone;
{
  return [[[IFTree alloc] initWithGraph:[graph clone]] autorelease];
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

- (IFTreeNode*)root;
{
  NSSet* roots = [graph sinkNodes];
  NSAssert([roots count] <= 1, @"too many roots");
  return [roots count] == 0 ? nil : [roots anyObject];
}

- (void)addNode:(IFTreeNode*)node;
{
  [graph addNode:node];
}

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
{
  NSSet* inEdges = [graph incomingEdgesForNode:node];
  NSMutableArray* parents = [NSMutableArray arrayWithCapacity:[inEdges count]];
  NSEnumerator* inEdgesEnum = [inEdges objectEnumerator];
  IFTreeEdge* inEdge;
  while (inEdge = [inEdgesEnum nextObject]) {
    while ([parents count] < [inEdge targetIndex] + 1)
      [parents addObject:[NSNull null]];
    [parents replaceObjectAtIndex:[inEdge targetIndex] withObject:[graph edgeSource:inEdge]];
  }
  return parents;
}

- (IFTreeNode*)childOfNode:(IFTreeNode*)node;
{
  NSSet* succs = [graph successorsOfNode:node];
  NSAssert([succs count] <= 1, @"too many successors for node");
  return [succs count] == 0 ? nil : [succs anyObject];
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

#pragma mark High level editing

- (void)addRightGhostParentsForNode:(IFTreeNode*)node;
{
  for (int i = [self parentsCountOfNode:node]; i < [node inputArity]; ++i) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:0];
    [graph addNode:ghost];
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:ghost toNode:node];
  }
}

- (void)removeAllRightGhostParentsOfNode:(IFTreeNode*)node;
{
  for (;;) {
    IFTreeNode* lastParent = [[self parentsOfNode:node] lastObject];
    if (lastParent == nil || ![self isGhostSubtreeRoot:lastParent])
      break;
    [[graph do] removeNode:[[self dfsAncestorsOfNode:lastParent] each]];
  }
}

- (void)addNode:(IFTreeNode*)node asNewRootAtIndex:(unsigned)index;
{
  IFTreeNode* root = [self root];

  NSSet* rootInEdgesCopy = [[graph incomingEdgesForNode:root] copy];
  NSEnumerator* rootInEdgesEnum = [rootInEdgesCopy objectEnumerator];
  IFTreeEdge* inEdge;
  while (inEdge = [rootInEdgesEnum nextObject]) {
    if ([inEdge targetIndex] >= index) {
      [graph addEdge:[IFTreeEdge edgeWithTargetIndex:[inEdge targetIndex] + 1] fromNode:[graph edgeSource:inEdge] toNode:root];
      [graph removeEdge:inEdge];
    }
  }
  [rootInEdgesCopy release];
  
  [graph addNode:node];
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:index] fromNode:node toNode:root];
}

- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
{
  [graph addNode:parent];
  NSSet* childInEdgesCopy = [[graph incomingEdgesForNode:child] copy];
  NSEnumerator* childInEdgesEnum = [childInEdgesCopy objectEnumerator];
  IFTreeEdge* childInEdge;
  while (childInEdge = [childInEdgesEnum nextObject]) {
    [graph addEdge:[childInEdge clone] fromNode:[graph edgeSource:childInEdge] toNode:parent];
    [graph removeEdge:childInEdge];
  }
  [childInEdgesCopy release];
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:0] fromNode:parent toNode:child];
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  [graph addNode:child];
  NSSet* parentOutEdges = [graph outgoingEdgesForNode:parent];
  NSAssert([parentOutEdges count] == 1, @"internal error");
  IFTreeEdge* parentOutEdge = [parentOutEdges anyObject];
  [graph addEdge:[parentOutEdge clone] fromNode:child toNode:[graph edgeTarget:parentOutEdge]];
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:0] fromNode:parent toNode:child];
  [graph removeEdge:parentOutEdge];
}

- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;
{
  IFTreeEdge* edge;
  [graph addNode:replacement];
  
  NSEnumerator* inEdgesEnum = [[graph incomingEdgesForNode:toReplace] objectEnumerator];
  while (edge = [inEdgesEnum nextObject])
    [graph addEdge:[edge clone] fromNode:[graph edgeSource:edge] toNode:replacement];

  NSEnumerator* outEdgesEnum = [[graph outgoingEdgesForNode:toReplace] objectEnumerator];
  while (edge = [outEdgesEnum nextObject])
    [graph addEdge:[edge clone] fromNode:replacement toNode:[graph edgeTarget:edge]];

  [graph removeNode:toReplace];
}

#pragma mark Type checking

- (BOOL)isCyclic;
{
  return [graph isCyclic];
}

- (BOOL)isTypeCorrect;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  NSArray* sortedNodes = [graph topologicallySortedNodes];
  if (sortedNodes == nil)
    return NO; // cyclic graph
  NSArray* sortedNodesNoRoot = [sortedNodes subarrayWithRange:NSMakeRange(0,[sortedNodes count] - 1)];
  return [typeChecker checkDAG:[self serialiseSortedNodes:sortedNodesNoRoot] withPotentialTypes:[[sortedNodesNoRoot collect] potentialTypes]];
}

- (NSDictionary*)resolveOverloading;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  NSArray* sortedNodes = [graph topologicallySortedNodes];
  NSAssert(sortedNodes != nil, @"attempt to resolve overloading in a cyclic graph");
  NSArray* sortedNodesNoRoot = [sortedNodes subarrayWithRange:NSMakeRange(0,[sortedNodes count] - 1)];
  NSArray* config = [typeChecker configureDAG:[self serialiseSortedNodes:sortedNodesNoRoot] withPotentialTypes:[[sortedNodesNoRoot collect] types]];
  NSMutableDictionary* configDict = createMutableDictionaryWithRetainedKeys();
  for (int i = 0; i < [sortedNodesNoRoot count]; ++i)
    CFDictionarySetValue((CFMutableDictionaryRef)configDict, [sortedNodesNoRoot objectAtIndex:i], [config objectAtIndex:i]);
  return configDict;
}

@end

@implementation IFTree (Private)

- (NSArray*)serialiseSortedNodes:(NSArray*)sortedNodes;
{
  const int nodesCount = [sortedNodes count];
  NSMutableArray* serialisedNodes = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    NSArray* preds = [self parentsOfNode:node];
    const int predsCount = [preds count];
    NSMutableArray* serialisedPreds = [NSMutableArray arrayWithCapacity:predsCount];
    for (int j = 0; j < predsCount; ++j)
      [serialisedPreds addObject:[NSNumber numberWithInt:[sortedNodes indexOfObject:[preds objectAtIndex:j]]]];
    [serialisedNodes addObject:serialisedPreds];
  }
  return serialisedNodes;
}

- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
{
  [[self do] dfsCollectAncestorsOfNode:[[self parentsOfNode:node] each] inArray:accumulator];
  [accumulator addObject:node];
}

@end