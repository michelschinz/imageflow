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
+ (id)treeWithNode:(IFTreeNode*)node;
+ (id)ghostTreeWithArity:(unsigned)arity;

- (IFTree*)clone;
- (IFTree*)cloneWithoutNewParentExpressionsPropagation;

// MARK: Navigation

@property(readonly) NSSet* nodes;
@property(readonly) IFTreeNode* root;

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
- (IFTreeNode*)childOfNode:(IFTreeNode*)node;
- (NSArray*)siblingsOfNode:(IFTreeNode*)node;
- (NSArray*)dfsAncestorsOfNode:(IFTreeNode*)node;
- (unsigned)ancestorsCountOfNode:(IFTreeNode*)node;

- (NSArray*)parentsOfSubtree:(IFSubtree*)subtree;
- (IFTreeNode*)childOfSubtree:(IFSubtree*)subtree;

- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;

@property(readonly) unsigned holesCount;

// MARK: Expression propagation

@property BOOL propagateNewParentExpressions;

// MARK: Low level editing

- (void)addNode:(IFTreeNode*)node;
- (void)addEdgeFromNode:(IFTreeNode*)fromNode toNode:(IFTreeNode*)toNode withIndex:(unsigned)index;

// MARK: High level editing

- (void)addCopyOfTree:(IFTree*)tree asNewRootAtIndex:(unsigned)index;

- (BOOL)canDeleteSubtree:(IFSubtree*)subtree;
- (void)deleteSubtree:(IFSubtree*)subtree;

- (BOOL)canCreateAliasToNode:(IFTreeNode*)original toReplaceNode:(IFTreeNode*)node;
- (void)createAliasToNode:(IFTreeNode*)original toReplaceNode:(IFTreeNode*)node;

  // Copying trees inside the current tree
- (BOOL)canCopyTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;
- (IFTreeNode*)copyTree:(IFTree*)tree toReplaceNode:(IFTreeNode*)node;

- (BOOL)canInsertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;
- (IFTreeNode*)insertCopyOfTree:(IFTree*)tree asChildOfNode:(IFTreeNode*)node;

- (BOOL)canInsertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;
- (IFTreeNode*)insertCopyOfTree:(IFTree*)tree asParentOfNode:(IFTreeNode*)node;

  // Moving subtrees to some other location
- (BOOL)canMoveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree toReplaceNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asChildOfNode:(IFTreeNode*)node;

- (BOOL)canMoveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;
- (void)moveSubtree:(IFSubtree*)subtree asParentOfNode:(IFTreeNode*)node;

// MARK: Type checking

- (BOOL)isTypeCorrect;
- (void)configureNodes;
- (void)configureAllNodesBut:(NSSet*)nonConfiguredNodes;

@end
