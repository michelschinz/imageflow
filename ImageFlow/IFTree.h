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

- (IFGraph*)graphOfNode:(IFTreeNode*)node;

- (IFTreeNode*)root;

- (void)addNode:(IFTreeNode*)node;

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
- (IFTreeNode*)childOfNode:(IFTreeNode*)node;

- (NSArray*)siblingsOfNode:(IFTreeNode*)node;

- (NSArray*)dfsAncestorsOfNode:(IFTreeNode*)node;

- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;

// obsolete (to be removed)
- (void)insertObject:(IFTreeNode*)newParent inParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index;
- (void)replaceObjectInParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index withObject:(IFTreeNode*)newParent;
- (void)removeObjectFromParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index;

@end
