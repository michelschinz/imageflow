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
#import "IFSubtree.h"

static NSString* IFTreeNodeExpressionChangedContext = @"IFTreeNodeExpressionChangedContext";

@interface IFTree (Private)
static NSArray* nodeParents(IFOrientedGraph* graph, IFTreeNode* node);
static NSArray* serialiseSortedNodes(IFOrientedGraph* graph, NSArray* sortedNodes);
static IFOrientedGraph* graphCloneWithoutAliases(IFOrientedGraph* graph);

- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;

- (void)debugDumpFrom:(IFTreeNode*)root indent:(unsigned)indent;
- (void)debugDump;
@end

@implementation IFTree

+ (id)tree;
{
  return [[[self alloc] init] autorelease];
}

- (id)initWithGraph:(IFOrientedGraph*)theGraph propagateNewParentExpressions:(BOOL)thePropagateNewParentExpressions;
{
  if (![super init])
    return nil;
  graph = [theGraph retain];
  propagateNewParentExpressions = NO;
  [self setPropagateNewParentExpressions:thePropagateNewParentExpressions];
  return self;
}

- (id)init;
{
  return [self initWithGraph:[IFOrientedGraph graph] propagateNewParentExpressions:NO];
}

- (void)dealloc;
{
  [self setPropagateNewParentExpressions:NO];
  OBJC_RELEASE(graph);
  [super dealloc];
}

- (IFTree*)clone;
{
  return [[[IFTree alloc] initWithGraph:[graph clone] propagateNewParentExpressions:propagateNewParentExpressions] autorelease];
}

- (IFTree*)cloneWithoutNewParentExpressionsPropagation;
{
  return [[[IFTree alloc] initWithGraph:[graph clone] propagateNewParentExpressions:NO] autorelease];
}

#pragma mark Navigation

- (NSSet*)nodes;
{
  return [graph nodes];
}

- (IFTreeNode*)root;
{
  NSSet* roots = [graph sinkNodes];
  NSAssert([roots count] <= 1, @"too many roots");
  return [roots count] == 0 ? nil : [roots anyObject];
}

- (void)addNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  [graph addNode:node];
}

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
{
  return nodeParents(graph,node);
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

#pragma mark Expression propagation

- (BOOL)propagateNewParentExpressions;
{
  return propagateNewParentExpressions;
}

- (void)setPropagateNewParentExpressions:(BOOL)newValue;
{
  if (newValue == propagateNewParentExpressions)
    return;

  NSEnumerator* nodesEnum = [[graph nodes] objectEnumerator];
  IFTreeNode* node;
  while (node = [nodesEnum nextObject]) {
    if (newValue)
      [node addObserver:self forKeyPath:@"expression" options:0 context:IFTreeNodeExpressionChangedContext];
    else
      [node removeObserver:self forKeyPath:@"expression"];
  }
  propagateNewParentExpressions = newValue;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert(propagateNewParentExpressions, @"internal error");
  NSAssert1(context == IFTreeNodeExpressionChangedContext, @"unexpected context: %@", context);

  IFTreeNode* node = object;
  NSSet* outEdges = [graph outgoingEdgesForNode:node];
  NSAssert([outEdges count] == 1, @"internal error");

  IFTreeEdge* outEdge = [outEdges anyObject];
  IFTreeNode* child = [graph edgeTarget:outEdge];
  [child setParentExpression:[node expression] atIndex:[outEdge targetIndex]];
}

#pragma mark High level editing

- (void)addRightGhostParentsForNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  for (int i = [self parentsCountOfNode:node]; i < [node inputArity]; ++i) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:0];
    [graph addNode:ghost];
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:ghost toNode:node];
  }
}

- (void)removeAllRightGhostParentsOfNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  for (;;) {
    IFTreeNode* lastParent = [[self parentsOfNode:node] lastObject];
    if (lastParent == nil || ![self isGhostSubtreeRoot:lastParent])
      break;
    [[graph do] removeNode:[[self dfsAncestorsOfNode:lastParent] each]];
  }
}

- (void)addNode:(IFTreeNode*)node asNewRootAtIndex:(unsigned)index;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
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
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
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
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  [graph addNode:child];
  NSSet* parentOutEdges = [graph outgoingEdgesForNode:parent];
  NSAssert([parentOutEdges count] == 1, @"internal error");
  IFTreeEdge* parentOutEdge = [parentOutEdges anyObject];
  [graph addEdge:[parentOutEdge clone] fromNode:child toNode:[graph edgeTarget:parentOutEdge]];
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:0] fromNode:parent toNode:child];
  [graph removeEdge:parentOutEdge];
}

- (void)replaceSubtree:(IFSubtree*)toReplace byNode:(IFTreeNode*)replacement;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  NSAssert([toReplace baseTree] == self, @"cannot replace subtree belonging to different tree");

  [graph addNode:replacement];

  // Create incoming edges
  NSSet* includedNodes = [toReplace includedNodes];
  NSArray* parentNodes = [toReplace sortedParentsOfInputNodes];
  for (int i = 0; i < [parentNodes count]; ++i)
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:[parentNodes objectAtIndex:i] toNode:replacement];

  // Create outgoing edge
  NSEnumerator* outEdgesEnum = [[graph outgoingEdgesForNode:[toReplace root]] objectEnumerator];
  IFTreeEdge* edge;
  while (edge = [outEdgesEnum nextObject])
    [graph addEdge:[edge clone] fromNode:replacement toNode:[graph edgeTarget:edge]];

  // Remove nodes
  [[graph do] removeNode:[includedNodes each]];
}

#pragma mark Type checking

- (BOOL)isCyclic;
{
  return [graphCloneWithoutAliases(graph) isCyclic];
}

- (BOOL)isTypeCorrect;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  IFOrientedGraph* cloneWithoutAliases = graphCloneWithoutAliases(graph);
  NSArray* sortedNodes = [cloneWithoutAliases topologicallySortedNodes];
  if (sortedNodes == nil)
    return NO; // cyclic graph
  NSArray* sortedNodesNoRoot = [sortedNodes subarrayWithRange:NSMakeRange(0,[sortedNodes count] - 1)];
  return [typeChecker checkDAG:serialiseSortedNodes(cloneWithoutAliases,sortedNodesNoRoot) withPotentialTypes:[[sortedNodesNoRoot collect] potentialTypes]];
}

- (void)configureNodes;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  IFOrientedGraph* cloneWithoutAliases = graphCloneWithoutAliases(graph);
  NSArray* sortedNodes = [cloneWithoutAliases topologicallySortedNodes];
  NSAssert(sortedNodes != nil, @"attempt to resolve overloading in a cyclic graph");
  NSArray* sortedNodesNoRoot = [sortedNodes subarrayWithRange:NSMakeRange(0,[sortedNodes count] - 1)];
  NSArray* config = [typeChecker configureDAG:serialiseSortedNodes(cloneWithoutAliases,sortedNodesNoRoot) withPotentialTypes:[[sortedNodesNoRoot collect] potentialTypes]];

  for (int i = 0; i < [config count]; ++i) {
    IFTreeNode* node = [sortedNodesNoRoot objectAtIndex:i];
    [node stopUpdatingExpression];
    NSArray* parents = [self parentsOfNode:node];
    for (int i = 0; i < [parents count]; ++i)
      [node setParentExpression:[[parents objectAtIndex:i] expression] atIndex:i];
    [node setActiveTypeIndex:[[config objectAtIndex:i] unsignedIntValue]];
    [node startUpdatingExpression];
  }
}


@end

@implementation IFTree (Private)

static NSArray* nodeParents(IFOrientedGraph* graph, IFTreeNode* node)
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

static NSArray* serialiseSortedNodes(IFOrientedGraph* graph, NSArray* sortedNodes)
{
  const int nodesCount = [sortedNodes count];
  NSMutableArray* serialisedNodes = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    NSArray* preds = nodeParents(graph,node);
    const int predsCount = [preds count];
    NSMutableArray* serialisedPreds = [NSMutableArray arrayWithCapacity:predsCount];
    for (int j = 0; j < predsCount; ++j)
      [serialisedPreds addObject:[NSNumber numberWithInt:[sortedNodes indexOfObject:[preds objectAtIndex:j]]]];
    [serialisedNodes addObject:serialisedPreds];
  }
  return serialisedNodes;
}

static IFOrientedGraph* graphCloneWithoutAliases(IFOrientedGraph* graph)
{
  IFOrientedGraph* clone = [graph clone];
  NSEnumerator* cloneNodesEnum = [[clone nodes] objectEnumerator];
  IFTreeNode* node;
  while (node = [cloneNodesEnum nextObject]) {
    if ([node isAlias]) {
      NSSet* outEdges = [clone outgoingEdgesForNode:node];
      NSCAssert([outEdges count] == 1, @"internal error");
      IFTreeEdge* outEdge = [outEdges anyObject];
      [clone addEdge:[IFTreeEdge edgeWithTargetIndex:[outEdge targetIndex]] fromNode:[node original] toNode:[clone edgeTarget:outEdge]];
      [clone removeNode:node];
    }
  }
  return clone;
}

- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
{
  [[self do] dfsCollectAncestorsOfNode:[[self parentsOfNode:node] each] inArray:accumulator];
  [accumulator addObject:node];
}

#pragma mark -
#pragma mark Debugging

- (void)debugDumpFrom:(IFTreeNode*)root indent:(unsigned)indent;
{
  NSLog(@"%2d %@", indent, [[root filter] expression]);
  NSArray* parents = [self parentsOfNode:root];
  for (int i = 0; i < [parents count]; ++i)
    [self debugDumpFrom:[parents objectAtIndex:i] indent:indent+1];
}

- (void)debugDump;
{
  [self debugDumpFrom:[self root] indent:0];
}

@end