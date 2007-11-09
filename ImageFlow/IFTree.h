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

- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;

#pragma mark Expression propagation

- (BOOL)propagateNewParentExpressions;
- (void)setPropagateNewParentExpressions:(BOOL)newValue;

#pragma mark Low level editing

- (void)addNode:(IFTreeNode*)node;
- (void)addEdgeFromNode:(IFTreeNode*)fromNode toNode:(IFTreeNode*)toNode withIndex:(unsigned)index;

#pragma mark High level editing

- (void)addNode:(IFTreeNode*)node asNewRootAtIndex:(unsigned)index;

- (BOOL)canInsertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;

- (BOOL)canInsertNode:(IFTreeNode*)node asParentOf:(IFTreeNode*)child;
- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;

- (BOOL)canReplaceSubtree:(IFSubtree*)toReplace byNode:(IFTreeNode*)replacement;
- (void)replaceSubtree:(IFSubtree*)toReplace byNode:(IFTreeNode*)replacement;

- (BOOL)canReplaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;
- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;

- (void)deleteSubtree:(IFSubtree*)subtree;

#pragma mark Type checking

- (BOOL)isCyclic;
- (BOOL)isTypeCorrect;
- (void)configureNodes;

@end
