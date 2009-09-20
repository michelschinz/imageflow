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
#import "IFTreeNodeAlias.h"

static NSString* IFTreeNodeExpressionChangedContext = @"IFTreeNodeExpressionChangedContext";

static NSArray* nodeParents(IFOrientedGraph* graph, IFTreeNode* node);
static NSArray* serialiseSortedNodes(IFOrientedGraph* graph, NSArray* sortedNodes);
static IFOrientedGraph* graphCloneWithoutAliases(IFOrientedGraph* graph);

@interface IFTree ()
- (unsigned)arityOfSubtree:(IFSubtree*)subtree;
- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
- (void)collectParentsOfSubtree:(IFSubtree*)subtree startingAt:(IFTreeNode*)root into:(NSMutableArray*)result;
- (IFTreeEdge*)outgoingEdgeForNode:(IFTreeNode*)node;
- (NSArray*)holesInSubtreeRootedAt:(IFTreeNode*)root;
- (IFTreeNode*)addCloneOfTree:(IFTree*)tree;
- (IFTreeNode*)addGhostTreeWithArity:(unsigned)arity;
- (IFTreeNode*)insertNewGhostNodeAsChildOf:(IFTreeNode*)node;
- (IFTreeNode*)insertNewGhostNodeAsParentOf:(IFTreeNode*)node;
- (IFTreeNode*)detachNode:(IFTreeNode*)node;
- (void)removeTreeRootedAt:(IFTreeNode*)node;
- (void)plugHole:(IFTreeNode*)hole withNode:(IFTreeNode*)node;
- (void)exchangeSubtree:(IFSubtree*)subtree withTreeRootedAt:(IFTreeNode*)root;
- (BOOL)canDeleteNode:(IFTreeNode*)node;
- (void)deleteNode:(IFTreeNode*)node;
@end

@implementation IFTree

+ (id)tree;
{
  return [[[self alloc] init] autorelease];
}

+ (id)treeWithNode:(IFTreeNode*)node;
{
  IFTree* tree = [self tree];
  [tree addNode:node];
  return tree;
}

+ (id)ghostTreeWithArity:(unsigned)arity;
{
  IFTree* tree = [self tree];
  IFTreeNode* ghost = [IFTreeNode ghostNode];
  [tree addNode:ghost];
  for (unsigned i = 0; i < arity; ++i) {
    IFTreeNode* holeParent = [IFTreeNodeHole hole];
    [tree addNode:holeParent];
    [tree addEdgeFromNode:holeParent toNode:ghost withIndex:i];
  }
  return tree;
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

// MARK: Navigation

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
  return [graph inDegree:node];
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

- (unsigned)ancestorsCountOfNode:(IFTreeNode*)node;
{
  unsigned count = 1;
  for (IFTreeNode* parent in [self parentsOfNode:node])
    count += [self ancestorsCountOfNode:parent];
  return count;
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

- (unsigned)holesCount;
{
  unsigned count = 0;
  for (IFTreeNode* node in [graph nodes]) {
    if ([node isHole])
      ++count;
  }
  return count;
}

// MARK: Expression propagation

@synthesize propagateNewParentExpressions;

- (void)setPropagateNewParentExpressions:(BOOL)newValue;
{
  if (newValue == propagateNewParentExpressions)
    return;

  NSMutableSet* nodes = [NSMutableSet setWithSet:[graph nodes]];
  [nodes removeObject:[self root]];
  if (newValue) {
    for (IFTreeNode* node in nodes)
      [node addObserver:self forKeyPath:@"expression" options:0 context:IFTreeNodeExpressionChangedContext];
  }
  else {
    for (IFTreeNode* node in nodes)
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
  NSAssert(outEdge != nil, @"internal error");
  IFTreeNode* child = [graph edgeTarget:outEdge];
  [child setParentExpression:[node expression] atIndex:[outEdge targetIndex]];
}

// MARK: Low level editing

- (void)addNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  [graph addNode:node];
}

- (void)addEdgeFromNode:(IFTreeNode*)fromNode toNode:(IFTreeNode*)toNode withIndex:(unsigned)index;
{
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:index] fromNode:fromNode toNode:toNode];
}

// MARK: High level editing

- (IFTreeNode*)addCloneOfTree:(IFTree*)tree asNewRootAtIndex:(unsigned)index;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  IFTreeNode* root = [self root];
  
  for (IFTreeEdge* inEdge in [[[graph incomingEdgesForNode:root] copy] autorelease]) {
    if ([inEdge targetIndex] >= index) {
      [graph addEdge:[IFTreeEdge edgeWithTargetIndex:[inEdge targetIndex] + 1] fromNode:[graph edgeSource:inEdge] toNode:root];
      [graph removeEdge:inEdge];
    }
  }

  IFTreeNode* addedTreeRoot = [self addCloneOfTree:tree];
  [self addEdgeFromNode:addedTreeRoot toNode:root withIndex:index];
  return addedTreeRoot;
}

- (BOOL)canDeleteSubtree:(IFSubtree*)subtree;
{
  return [[subtree includedNodes] count] > 1 || ![[subtree root] isGhost] || [self canDeleteNode:[subtree root]];
}

- (IFTreeNode*)deleteSubtree:(IFSubtree*)subtree;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");

  // Replace subtree to delete by a single ghost.
  IFTreeNode* ghostRoot = [self addGhostTreeWithArity:[self arityOfSubtree:subtree]];
  [self exchangeSubtree:subtree withTreeRootedAt:ghostRoot];
  [self removeTreeRootedAt:[subtree root]];

  // Try to delete the ghost too.
  if ([self canDeleteNode:ghostRoot]) {
    [self deleteNode:ghostRoot];
    return nil;
  } else
    return ghostRoot;
}

- (BOOL)canCreateAliasToNode:(IFTreeNode*)original toReplaceNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone createAliasToNode:original toReplaceNode:node];
  return [clone isTypeCorrect];
}

- (IFTreeNode*)createAliasToNode:(IFTreeNode*)original toReplaceNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");

  IFTreeNode* alias = [IFTreeNodeAlias nodeAliasWithOriginal:original];
  [self addNode:alias];
  [self exchangeSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:node]] withTreeRootedAt:alias];
  [self removeTreeRootedAt:node];
  return alias;
}

// Copying trees inside the current tree
- (BOOL)canCloneTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone cloneTree:tree toReplaceNode:node];
  return [clone isTypeCorrect];
}

- (IFTreeNode*)cloneTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");

  IFTreeNode* copiedTreeRoot = [self addCloneOfTree:tree];
  [self exchangeSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:node]] withTreeRootedAt:copiedTreeRoot];
  [self removeTreeRootedAt:node];
  return copiedTreeRoot;
}

- (BOOL)canInsertCloneOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone insertCloneOfTree:tree asChildOfNode:node];
  return [clone isTypeCorrect];
}

- (IFTreeNode*)insertCloneOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
{
  return [self cloneTree:tree toReplaceNode:[self insertNewGhostNodeAsChildOf:node]];
}

- (BOOL)canInsertCloneOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone insertCloneOfTree:tree asParentOfNode:node];
  return [clone isTypeCorrect];
}

- (IFTreeNode*)insertCloneOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
{
  return [self cloneTree:tree toReplaceNode:[self insertNewGhostNodeAsParentOf:node]];
}

  // Moving subtrees to some other location
- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;
{
  if ([subtree containsNode:node])
    return NO;

  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  IFSubtree* cloneSubtree = [IFSubtree subtreeOf:clone includingNodes:[subtree includedNodes]];
  [clone moveSubtree:cloneSubtree toReplaceNode:node];
  return [clone isTypeCorrect];
}

- (void)moveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  
  IFTreeNode* ghost = [self addGhostTreeWithArity:[self arityOfSubtree:subtree]];
  [self exchangeSubtree:subtree withTreeRootedAt:ghost];
  [self exchangeSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:node]] withTreeRootedAt:[subtree root]];
  [self removeTreeRootedAt:node];

  // Try to delete the ghost too.
  if ([self canDeleteNode:ghost])
    [self deleteNode:ghost];
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
{
  if ([subtree containsNode:node] && [subtree containsNode:[self childOfNode:node]])
    return NO;

  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  IFSubtree* cloneSubtree = [IFSubtree subtreeOf:clone includingNodes:[subtree includedNodes]];
  [clone moveSubtree:cloneSubtree asChildOfNode:node];
  return [clone isTypeCorrect];
}

- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
{
  [self moveSubtree:subtree toReplaceNode:[self insertNewGhostNodeAsChildOf:node]];
}

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
{
  NSSet* parentsSet = [NSSet setWithArray:[self parentsOfNode:node]];
  if ([subtree containsNode:node] && [[subtree includedNodes] intersectsSet:parentsSet])
    return NO;
  
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  IFSubtree* cloneSubtree = [IFSubtree subtreeOf:clone includingNodes:[subtree includedNodes]];
  [clone moveSubtree:cloneSubtree asParentOfNode:node];
  return [clone isTypeCorrect];
}

- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
{
  [self moveSubtree:subtree toReplaceNode:[self insertNewGhostNodeAsParentOf:node]];
}

// MARK: Type checking

- (BOOL)isTypeCorrect;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  IFOrientedGraph* cloneWithoutAliases = graphCloneWithoutAliases(graph);
  NSArray* sortedNodes = [cloneWithoutAliases topologicallySortedNodes];
  if (sortedNodes == nil)
    return NO; // cyclic graph
  NSArray* sortedNodesNoRoot = [sortedNodes subarrayWithRange:NSMakeRange(0,[sortedNodes count] - 1)];
  NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:[sortedNodesNoRoot count]];
  for (IFTreeNode* node in sortedNodesNoRoot)
    [potentialTypes addObject:[node potentialTypesForArity:[self parentsCountOfNode:node]]];
  return [typeChecker checkDAG:serialiseSortedNodes(cloneWithoutAliases, sortedNodesNoRoot) withPotentialTypes:potentialTypes];
}

- (void)configureNodes;
{
  [self configureAllNodesBut:[NSSet set]];
}

- (void)configureAllNodesBut:(NSSet*)nonConfiguredNodes;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  IFOrientedGraph* cloneWithoutAliases = graphCloneWithoutAliases(graph);
  NSArray* sortedNodes = [cloneWithoutAliases topologicallySortedNodes];
  NSAssert(sortedNodes != nil, @"attempt to resolve overloading in a cyclic graph");
  const unsigned nodesCount = [sortedNodes count];
  
  NSMutableArray* potentialTypes = [NSMutableArray arrayWithCapacity:nodesCount];
  for (IFTreeNode* node in sortedNodes)
    [potentialTypes addObject:[node potentialTypesForArity:[self parentsCountOfNode:node]]];
  NSArray* config = [typeChecker configureDAG:serialiseSortedNodes(cloneWithoutAliases, sortedNodes) withPotentialTypes:potentialTypes];
  NSAssert(config != nil, @"unable to configure DAG");

  NSMutableDictionary* nodeExpressions = [createMutableDictionaryWithRetainedKeys() autorelease];
  for (unsigned i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    
    NSMutableDictionary* parentExpressions = [NSMutableDictionary dictionaryWithCapacity:5];
    unsigned j = 0;
    for (IFTreeNode* parent in [self parentsOfNode:node])
      [parentExpressions setObject:[nodeExpressions objectForKey:parent.original] forKey:[NSNumber numberWithUnsignedInt:j++]];
    
    NSArray* nodeConfig = [config objectAtIndex:i];
    unsigned activeTypeIndex = [[nodeConfig objectAtIndex:0] unsignedIntValue];
    IFExpression* nodeExpression = [node expressionForSettings:node.settings parentExpressions:parentExpressions activeTypeIndex:activeTypeIndex];
    CFDictionarySetValue((CFMutableDictionaryRef)nodeExpressions, node, nodeExpression);
    if (![nonConfiguredNodes containsObject:node])
      [node setParentExpressions:parentExpressions activeTypeIndex:activeTypeIndex type:[nodeConfig objectAtIndex:1]];
  }
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithGraph:[decoder decodeObjectForKey:@"graph"] propagateNewParentExpressions:[decoder decodeBoolForKey:@"propagateNewParentExpressions"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:graph forKey:@"graph"];
  [encoder encodeBool:propagateNewParentExpressions forKey:@"propagateNewParentExpressions"];
}

// MARK: -
// MARK: PRIVATE

- (unsigned)arityOfSubtree:(IFSubtree*)subtree;
{
  return [[self parentsOfSubtree:subtree] count];
}

- (void)dfsCollectAncestorsOfNode:(IFTreeNode*)node inArray:(NSMutableArray*)accumulator;
{
  for (IFTreeNode* parent in [self parentsOfNode:node])
    [self dfsCollectAncestorsOfNode:parent inArray:accumulator];
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
  NSAssert([outEdges count] <= 1, @"more than one outgoing edge for tree node");
  return [outEdges count] == 0 ? nil : [outEdges anyObject];
}

// MARK: Low level editing

- (void)collectHolesInSubtreeRootedAt:(IFTreeNode*)root into:(NSMutableArray*)result;
{
  if ([root isHole])
    [result addObject:root];
  else {
    for (IFTreeNode* parent in [self parentsOfNode:root])
      [self collectHolesInSubtreeRootedAt:parent into:result];
  }
}

- (NSArray*)holesInSubtreeRootedAt:(IFTreeNode*)root;
{
  NSMutableArray* holes = [NSMutableArray array];
  [self collectHolesInSubtreeRootedAt:root into:holes];
  return holes;
}

- (void)addTree:(IFTree*)tree startingAtNode:(IFTreeNode*)root;
{
  [graph addNode:root];
  NSArray* parents = [tree parentsOfNode:root];
  for (int i = 0; i < [parents count]; ++i) {
    IFTreeNode* parent = [parents objectAtIndex:i];
    [self addTree:tree startingAtNode:parent];
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:parent toNode:root];
  }
}

- (IFTreeNode*)addCloneOfTree:(IFTree*)tree;
{
  IFTree* clone = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:tree]];
  [self addTree:clone startingAtNode:[clone root]];
  return [clone root];
}

- (IFTreeNode*)addGhostTreeWithArity:(unsigned)arity;
{
  IFTreeNode* ghost = [IFTreeNode ghostNode];
  [self addNode:ghost];

  for (int i = 0; i < arity; ++i) {
    IFTreeNode* hole = [IFTreeNodeHole hole];
    [self addNode:hole];
    [self addEdgeFromNode:hole toNode:ghost withIndex:i];
  }
  return ghost;
}

- (IFTreeNode*)insertNewGhostNodeAsChildOf:(IFTreeNode*)node;
{
  IFTreeNode* ghost = [IFTreeNode ghostNode];
  [graph addNode:ghost];

  IFTreeEdge* parentOutEdge = [self outgoingEdgeForNode:node];
  if (parentOutEdge != nil) {
    [graph addEdge:[parentOutEdge clone] fromNode:ghost toNode:[graph edgeTarget:parentOutEdge]];
    [graph removeEdge:parentOutEdge];
  }
  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:0] fromNode:node toNode:ghost];
  return ghost;
}

- (IFTreeNode*)insertNewGhostNodeAsParentOf:(IFTreeNode*)node;
{
  NSSet* inEdges = [graph incomingEdgesForNode:node];
  IFTreeNode* ghost = [IFTreeNode ghostNode];
  [graph addNode:ghost];

  for (IFTreeEdge* inEdge in inEdges) {
    [graph addEdge:[inEdge clone] fromNode:[graph edgeSource:inEdge] toNode:ghost];
    [graph removeEdge:inEdge];
  }

  [graph addEdge:[IFTreeEdge edgeWithTargetIndex:0] fromNode:ghost toNode:node];
  for (int i = 1; i < [inEdges count]; ++i) {
    IFTreeNode* ghostParent = [IFTreeNode ghostNode];
    [graph addNode:ghostParent];
    [graph addEdge:[IFTreeEdge edgeWithTargetIndex:i] fromNode:ghostParent toNode:node];
  }
  return ghost;
}

- (IFTreeNode*)detachNode:(IFTreeNode*)node;
{
  IFTreeNode* hole = [IFTreeNodeHole hole];
  [graph addNode:hole];
  IFTreeEdge* outEdge = [self outgoingEdgeForNode:node];
  if (outEdge != nil) {
    [graph addEdge:[outEdge clone] fromNode:hole toNode:[graph edgeTarget:outEdge]];
    [graph removeEdge:outEdge];
  }
  return hole;
}

- (void)removeTreeRootedAt:(IFTreeNode*)root;
{
  NSAssert([[graph outgoingEdgesForNode:root] count] == 0, @"trying to remove subtree");
  NSSet* nodesToRemove = [NSSet setWithArray:[self dfsAncestorsOfNode:root]];
  
  // Replace all aliases to nodes about to be deleted by ghosts.
  for (IFTreeNode* node in [self nodes]) {
    if ([node isAlias] && ![nodesToRemove containsObject:node] && [nodesToRemove containsObject:[node original]])
      [self cloneTree:[IFTree ghostTreeWithArity:0] toReplaceNode:node];
  }

  for (IFTreeNode* node in nodesToRemove)
    [graph removeNode:node];
}

- (void)plugHole:(IFTreeNode*)hole withNode:(IFTreeNode*)node;
{
  NSAssert([hole isHole], @"attempt to plug non-hole");
  IFTreeEdge* outEdge = [self outgoingEdgeForNode:hole];
  if (outEdge != nil)
    [graph addEdge:[outEdge clone] fromNode:node toNode:[graph edgeTarget:outEdge]];
  [graph removeNode:hole];
}

- (void)exchangeSubtree:(IFSubtree*)subtree withTreeRootedAt:(IFTreeNode*)root;
{
  IFTreeNode* subtreeHole = [self detachNode:[subtree root]];
  [self plugHole:subtreeHole withNode:root];

  NSArray* subtreeParents = [self parentsOfSubtree:subtree];
  for (IFTreeNode* parent in subtreeParents)
    [self detachNode:parent];
  const unsigned parentsCount = [subtreeParents count];

  NSArray* treeHoles = [self holesInSubtreeRootedAt:root];
  const unsigned holesCount = [treeHoles count];

  for (int i = 0, minCount = parentsCount < holesCount ? parentsCount : holesCount; i < minCount; ++i) {
    IFTreeNode* hole = [treeHoles objectAtIndex:i];
    IFTreeNode* parent = [subtreeParents objectAtIndex:i];
    [self plugHole:hole withNode:parent];
    if (root == hole)
      root = parent;
  }
  
  if (parentsCount > holesCount) {
    // more parents than holes, attach remaining ones to new root (rightmost, ghost-only parents excepted).
    BOOL active = NO;
    for (int i = parentsCount - 1; i >= (int)holesCount; --i) {
      IFTreeNode* parent = [subtreeParents objectAtIndex:i];
      active |= ![self isGhostSubtreeRoot:parent];
      if (active)
        [self addEdgeFromNode:parent toNode:root withIndex:[self parentsCountOfNode:root]];
      else
        [self removeTreeRootedAt:parent];
    }
  } else if (holesCount > parentsCount) {
    // more holes than parents, plug them with ghosts
    for (int i = parentsCount; i < holesCount; ++i) {
      IFTreeNode* ghost = [IFTreeNode ghostNode];
      [self addNode:ghost];
      [self plugHole:[treeHoles objectAtIndex:i] withNode:ghost];
    }
  }
}

- (BOOL)canDeleteNode:(IFTreeNode*)node;
{
  IFTree* clone = [self cloneWithoutNewParentExpressionsPropagation];
  [clone deleteNode:node];
  return [clone isTypeCorrect];
}

- (void)deleteNode:(IFTreeNode*)node;
{
  NSAssert(!propagateNewParentExpressions, @"cannot modify tree structure while propagating parent expressions");
  
  IFTreeNode* hole = [IFTreeNodeHole hole];
  [self addNode:hole];
  [self exchangeSubtree:[IFSubtree subtreeOf:self includingNodes:[NSSet setWithObject:node]] withTreeRootedAt:hole];
  [self removeTreeRootedAt:node];
}

@end

static NSArray* nodeParents(IFOrientedGraph* graph, IFTreeNode* node)
{
  NSSet* inEdges = [graph incomingEdgesForNode:node];
  NSMutableArray* parents = [NSMutableArray arrayWithCapacity:[inEdges count]];
  for (IFTreeEdge* inEdge in inEdges) {
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
  NSMutableSet* nodesToRemove = [NSMutableSet set];
  for (IFTreeNode* node in [clone nodes]) {
    if ([node isAlias]) {
      NSSet* outEdges = [clone outgoingEdgesForNode:node];
      NSCAssert([outEdges count] == 1, @"internal error");
      IFTreeEdge* outEdge = [outEdges anyObject];
      [clone addEdge:[IFTreeEdge edgeWithTargetIndex:[outEdge targetIndex]] fromNode:[node original] toNode:[clone edgeTarget:outEdge]];
      [nodesToRemove addObject:node];
    }
  }
  for (IFTreeNode* node in nodesToRemove)
    [clone removeNode:node];
  return clone;
}

