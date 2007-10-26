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
  IFOrientedGraph* graph;
}

+ (id)tree;

- (IFTree*)clone;

- (IFGraph*)graphOfNode:(IFTreeNode*)node;

- (IFTreeNode*)root;

- (void)addNode:(IFTreeNode*)node;

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
- (IFTreeNode*)childOfNode:(IFTreeNode*)node;

- (NSArray*)siblingsOfNode:(IFTreeNode*)node;

- (NSArray*)dfsAncestorsOfNode:(IFTreeNode*)node;

- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;

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
- (NSDictionary*)resolveOverloading;

@end
