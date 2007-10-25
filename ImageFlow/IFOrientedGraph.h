//
//  IFOrientedGraph.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFOrientedGraph : NSObject {
  NSMutableSet* nodes;
  NSMutableDictionary* edgeToRealEdge;
  NSMutableDictionary* nodeToEdgeSet;
}

+ (id)graph;

- (id)clone;

- (NSSet*)nodes;

- (void)addNode:(id)node;
- (void)removeNode:(id)node;
- (BOOL)containsNode:(id)node;
- (NSSet*)predecessorsOfNode:(id)node;
- (NSSet*)successorsOfNode:(id)node;

- (NSSet*)sourceNodes;
- (NSSet*)sinkNodes;

- (void)addEdge:(id)edge fromNode:(id)fromNode toNode:(id)toNode;
- (void)removeEdge:(id)edge;
- (BOOL)containsEdge:(id)edge;
- (id)edgeSource:(id)edge;
- (id)edgeTarget:(id)edge;

- (NSSet*)allEdgesForNode:(id)node;
- (NSSet*)incomingEdgesForNode:(id)node;
- (unsigned)inDegree:(id)node;
- (NSSet*)outgoingEdgesForNode:(id)node;
- (unsigned)outDegree:(id)node;

- (NSArray*)topologicallySortedNodes;
- (BOOL)isCyclic;

@end
