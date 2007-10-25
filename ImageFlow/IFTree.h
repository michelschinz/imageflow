//
//  IFTree.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTree : NSObject {

}

+ (id)tree;

- (IFGraph*)graphOfNode:(IFTreeNode*)node;

- (NSArray*)parentsOfNode:(IFTreeNode*)node;
- (IFTreeNode*)childOfNode:(IFTreeNode*)node;

- (NSArray*)siblingsOfNode:(IFTreeNode*)node;

- (NSArray*)dfsAncestorsOfNode:(IFTreeNode*)node;

- (unsigned)parentsCountOfNode:(IFTreeNode*)node;
- (BOOL)isGhostSubtreeRoot:(IFTreeNode*)node;

- (void)insertObject:(IFTreeNode*)newParent inParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index;
- (void)replaceObjectInParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index withObject:(IFTreeNode*)newParent;
- (void)removeObjectFromParentsOfNode:(IFTreeNode*)node atIndex:(unsigned)index;

@end
