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

@interface IFTree : NSObject {
  BOOL propagateNewParentExpressions;
  IFOrientedGraph* graph;
}

+ (id)tree;

- (IFTree*)clone;
- (IFTree*)cloneWithoutNewParentExpressionsPropagation;

#pragma mark Navigation
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

#pragma mark High level editing

- (void)addRightGhostParentsForNode:(IFTreeNode*)node;
- (void)removeAllRightGhostParentsOfNode:(IFTreeNode*)node;

- (void)addNode:(IFTreeNode*)node asNewRootAtIndex:(unsigned)index;
- (void)insertNode:(IFTreeNode*)parent asParentOf:(IFTreeNode*)child;
- (void)insertNode:(IFTreeNode*)child asChildOf:(IFTreeNode*)parent;
- (void)replaceNode:(IFTreeNode*)toReplace byNode:(IFTreeNode*)replacement;

#pragma mark Type checking

- (BOOL)isCyclic;
- (BOOL)isTypeCorrect;
- (void)configureNodes;

@end
