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
#import "IFTreeNodeHole.h"

static NSString* IFTreeNodeExpressionChangedContext = @"IFTreeNodeExpressionChangedContext";

static NSArray* nodeParents(IFOrientedGraph* graph, IFTreeNode* node);
static NSArray* serialiseSortedNodes(IFOrientedGraph* graph, NSArray* sortedNodes);
static IFOrientedGraph* graphCloneWithoutAliases(IFOrientedGraph* graph);

@interface IFTree (Private)
- (unsigned)arityOfSubtree:(IFSubtree*)subtree;
- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
- (void)collectParentsOfSubtree:(IFSubtree*)subtree startingAt:(IFTreeNode*)root into:(NSMutableArray*)result;
- (IFTreeEdge*)outgoingEdgeForNode:(IFTreeNode*)node;
- (NSArray*)holesInSubtreeRootedAt:(IFTreeNode*)root;
- (IFTreeNode*)addCopyOfTree:(IFTree*)tree;
- (IFTreeNode*)addGhostTreeWithArity:(unsigned)arity;
- (IFTreeNode*)detachNode:(IFTreeNode*)node;
- (void)removeNode:(IFTreeNode*)node;
- (void)removeTreeRootedAt:(IFTreeNode*)node;
- (void)plugHole:(IFTreeNode*)hole withNode:(IFTreeNode*)node;
- (void)exchangeSubtree:(IFSubtree*)subtree withTreeRootedAt:(IFTreeNode*)root;
- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;

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

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
{
  return nodeParents(graph,node);
}

- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
{
  return [[self parentsOfNode:node] count];
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

- (NSArray*)parentsOfSubtree:(IFSubtree*)subtree;
{
  NSAssert([subtree baseTree] == self, @"invalid subtree");
  NSMutableArray* parents = [NSMutableArray array];
  [self collectParentsOfSubtree:subtree startingAt:[subtree root] into:parents];
  return parents;
}

- (IFTreeNode*)childOfSubtree:(IFSubtree*)subtree;
{
  NSAssert([subtree baseTree] == self, @"invalid subtree");
  return [self childOfNode:[subtree root]];
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
  IFTreeEdge* outEdge = [self outgoingEdgeForNode:node];
  IFTreeNode* child = [graph edgeTarget:outEdge];
  [child setParentExpression:[node expression] atIndex:[outEdge targetIndex]];
}

#pragma mark Low level editing

- (void)addNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  [graph addNode:node];
}

- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
{
  [graph addNode:child];
  IFTreeEdge* parentOutEdge = [self outgoingEdgeForNode:parent];
  [graph addEdge:[parentOutEdge clone] fromNode:child toNode:[graph edgeTarget:parentOutEdge]];
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:0] fromNode:parent toNode:child];
  [graph removeEdge:parentOutEdge];
}

- (void)addEdgeFromNode:(IFTreeNode*)fromNode toNode:(IFTreeNode*)toNode withIndex:(unsigned)index;
{
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:index] fromNode:fromNode toNode:toNode];
}

#pragma mark High level editing

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

- (void)deleteSubtree:(IFSubtree*)subtree;
{
  // First replace all aliases to nodes about to be deleted by ghosts...
  NSEnumerator* allNodesEnum = [[self nodes] objectEnumerator];
  IFTreeNode* node;
  while (node = [allNodesEnum nextObject]) {
    if ([node isAlias] && ![subtree containsNode:node] && [subtree containsNode:[node original]])
      [self replaceNode:node byNode:[IFTreeNode ghostNodeWithInputArity:0]];
  }
  
  IFTreeNode* ghostRoot = [self addGhostTreeWithArity:[self arityOfSubtree:subtree]];
  [self exchangeSubtree:subtree withTreeRootedAt:ghostRoot];
  [self removeTreeRootedAt:[subtree root]];
}

// Copying trees inside the current tree
- (BOOL)canCopyTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone copyTree:tree toReplaceNode:node];
  return [clone isTypeCorrect];
}

- (void)copyTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;
{
  IFTreeNode* copiedTreeRoot = [self addCopyOfTree:tree];
  [self exchangeSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:node]] withTreeRootedAt:copiedTreeRoot];
  [self removeTreeRootedAt:node];
}

- (BOOL)canInsertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone insertCopyOfTree:tree asChildOfNode:node];
  return [clone isTypeCorrect];
}

- (void)insertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
{
  IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:1];
  [self insertNode:ghost asChildOf:node];
  [self copyTree:tree toReplaceNode:ghost];
}

- (BOOL)canInsertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone insertCopyOfTree:tree asParentOfNode:node];
  return [clone isTypeCorrect];
}

- (void)insertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
{
  // TODO
}

  // Moving subtrees to some other location
- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone moveSubtree:subtree toReplaceNode:node];
  return [clone isTypeCorrect];
}

- (void)moveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;
{
  IFTreeNode* ghost = [self addGhostTreeWithArity:[self arityOfSubtree:subtree]];
  [self exchangeSubtree:subtree withTreeRootedAt:ghost];
  [self exchangeSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:node]] withTreeRootedAt:[subtree root]];
  [self removeTreeRootedAt:node];
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone moveSubtree:subtree asChildOfNode:node];
  return [clone isTypeCorrect];
}

- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
{
  // TODO
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone moveSubtree:subtree asParentOfNode:node];
  return [clone isTypeCorrect];
}

- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
{
  // TODO
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

#pragma NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithGraph:[decoder decodeObjectForKey:@"graph"] propagateNewParentExpressions:[decoder decodeBoolForKey:@"propagateNewParentExpressions"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:graph forKey:@"graph"];
  [encoder encodeBool:propagateNewParentExpressions forKey:@"propagateNewParentExpressions"];
}

@end

#pragma mark -

@implementation IFTree (Private)

- (unsigned)arityOfSubtree:(IFSubtree*)subtree;
{
  return [[self parentsOfSubtree:subtree] count];
}

- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
{
  [[self do] dfsCollectAncestorsOfNode:[[self parentsOfNode:node] each] inArray:accumulator];
  [accumulator addObject:node];
}

- (void)collectParentsOfSubtree:(IFSubtree*)subtree startingAt:(IFTreeNode*)root into:(NSMutableArray*)result;
{
  NSArray* parents = [self parentsOfNode:root];
  for (int i = 0; i < [parents count]; ++i) {
    IFTreeNode* parent = [parents objectAtIndex:i];
    if ([subtree containsNode:parent])
      [self collectParentsOfSubtree:subtree startingAt:parent into:result];
    else
      [result addObject:parent];
  }
}

- (IFTreeEdge*)outgoingEdgeForNode:(IFTreeNode*)node;
{
  NSSet* outEdges = [graph outgoingEdgesForNode:node];
  NSAssert([outEdges count] == 1, @"more than one outgoing edge for tree node");
  return [outEdges anyObject];
}

#pragma mark Low level editing

- (void)collectHolesInSubtreeRootedAt:(IFTreeNode*)root into:(NSMutableArray*)result;
{
  if ([root isHole])
    [result addObject:root];
  else
    [[self do] collectHolesInSubtreeRootedAt:[[self parentsOfNode:root] each] into:result];
}

- (NSArray*)holesInSubtreeRootedAt:(IFTreeNode*)root;
{
  NSMutableArray* holes = [NSMutableArray array];
  [self collectHolesInSubtreeRootedAt:root into:holes];
  return holes;
}

- (IFTreeNode*)addCopyOfTree:(IFTree*)tree startingAtNode:(IFTreeNode*)root;
{
  IFTreeNode* copiedRoot = [root cloneNode];
  [graph addNode:copiedRoot];

  NSArray* parents = [tree parentsOfNode:root];
  for (int i = 0; i < [parents count]; ++i) {
    IFTreeNode* parent = [parents objectAtIndex:i];
    IFTreeNode* copiedParent = [self addCopyOfTree:tree startingAtNode:parent];
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:copiedParent toNode:copiedRoot];
  }
  return copiedRoot;
}

- (IFTreeNode*)addCopyOfTree:(IFTree*)tree;
{
  return [self addCopyOfTree:tree startingAtNode:[tree root]]; 
}

- (IFTreeNode*)addGhostTreeWithArity:(unsigned)arity;
{
  IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:arity];
  [self addNode:ghost];

  for (int i = 0; i < arity; ++i) {
    IFTreeNode* hole = [IFTreeNodeHole hole];
    [self addNode:hole];
    [self addEdgeFromNode:hole toNode:ghost withIndex:i];
  }
  return ghost;
}

- (IFTreeNode*)detachNode:(IFTreeNode*)node;
{
  IFTreeNode* hole = [IFTreeNodeHole hole];
  [graph addNode:hole];
  IFTreeEdge* outEdge = [self outgoingEdgeForNode:node];
  [graph addEdge:[outEdge clone] fromNode:hole toNode:[graph edgeTarget:outEdge]];
  [graph removeEdge:outEdge];
  return hole;
}

- (void)removeNode:(IFTreeNode*)node;
{
  [graph removeNode:node];
  // TODO remove aliases of node
}

- (void)removeTreeRootedAt:(IFTreeNode*)node;
{
  NSAssert([[graph outgoingEdgesForNode:node] count] == 0, @"trying to remove subtree");
  [[self do] removeNode:[[self dfsAncestorsOfNode:node] each]];
}

- (void)plugHole:(IFTreeNode*)hole withNode:(IFTreeNode*)node;
{
  NSAssert([hole isHole], @"attempt to plug non-hole");
  IFTreeEdge* outEdge = [self outgoingEdgeForNode:hole];
  [graph addEdge:[outEdge clone] fromNode:node toNode:[graph edgeTarget:outEdge]];
  [self removeNode:hole];
}

- (void)exchangeSubtree:(IFSubtree*)subtree withTreeRootedAt:(IFTreeNode*)root;
{
  IFTreeNode* subtreeHole = [self detachNode:[subtree root]];
  [self plugHole:subtreeHole withNode:root];

  NSArray* subtreeParents = [self parentsOfSubtree:subtree];
  [[self do] detachNode:[subtreeParents each]];

  NSArray* treeHoles = [self holesInSubtreeRootedAt:root];
  for (int i = 0; i < [subtreeParents count]; ++i)
    [self plugHole:[treeHoles objectAtIndex:i] withNode:[subtreeParents objectAtIndex:i]];
  for (int i = [subtreeParents count]; i < [treeHoles count]; ++i) {
    IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:0];
    [self addNode:ghost];
    [self plugHole:[treeHoles objectAtIndex:i] withNode:ghost];
  }
}

// TODO try to remove
- (void)replaceSubtree:(IFSubtree*)toReplace byNode:(IFTreeNode*)replacement;
{
  [graph addNode:replacement];
  
  // Create incoming edges
  NSSet* includedNodes = [toReplace includedNodes];
  NSArray* parentNodes = [self parentsOfSubtree:toReplace];
  for (int i = 0; i < [parentNodes count]; ++i)
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:[parentNodes objectAtIndex:i] toNode:replacement];
  
  // Create outgoing edge
  IFTreeEdge* edge = [self outgoingEdgeForNode:[toReplace root]];
  [graph addEdge:[edge clone] fromNode:replacement toNode:[graph edgeTarget:edge]];
  
  // Remove nodes
  [[graph do] removeNode:[includedNodes each]];
}

// TODO try to remove
- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;
{
  return [self replaceSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:toReplace]] byNode:replacement];
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

