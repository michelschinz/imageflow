//
//  IFTree.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFOrientedGraph.h"
@class IFSubtree;

@interface IFTree : NSObject<NSCoding> {
  IFOrientedGraph* graph;
  BOOL propagateNewParentExpressions;
}

+ (id)tree;

- (IFTree*)clone;
- (IFTree*)cloneWithoutNewParentExpressionsPropagation;

#pragma mark Navigation

- (NSSet*)nodes;
- (IFTreeNode*)root;

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
- (IFTreeNode*)childOfNode:(IFTreeNode*)node;
- (NSArray*)siblingsOfNode:(IFTreeNode*)node;
- (NSArray*)dfsAncestorsOfNode:(IFTreeNode*)node;

- (NSArray*)parentsOfSubtree:(IFSubtree*)subtree;
- (IFTreeNode*)childOfSubtree:(IFSubtree*)subtree;

- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;

- (unsigned)holesCount;

#pragma mark Expression propagation

- (BOOL)propagateNewParentExpressions;
- (void)setPropagateNewParentExpressions:(BOOL)newValue;

#pragma mark Low level editing

- (void)addNode:(IFTreeNode*)node;
- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;

- (void)addEdgeFromNode:(IFTreeNode*)fromNode toNode:(IFTreeNode*)toNode withIndex:(unsigned)index;

#pragma mark High level editing

- (void)addNode:(IFTreeNode*)node asNewRootAtIndex:(unsigned)index;
- (void)deleteSubtree:(IFSubtree*)subtree;

  // Copying trees inside the current tree
- (BOOL)canCopyTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;
- (void)copyTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;

- (BOOL)canInsertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (void)insertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;

- (BOOL)canInsertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
- (void)insertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;

  // Moving subtrees to some other location
- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;

#pragma mark Type checking

- (void)configureNodes;

@end
