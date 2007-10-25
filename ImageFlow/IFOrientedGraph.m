//
//  IFOrientedGraph.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFOrientedGraph.h"
#import "IFOrientedGraphEdge.h"

@interface IFOrientedGraph (Private)
- (id)initWithNodes:(NSSet*)theNodes edgeToRealEdge:(NSDictionary*)theEdgeToRealEdge nodeToEdgeSet:(NSDictionary*)theNodeToEdgeSet;
@end

@implementation IFOrientedGraph

+ (id)graph;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  return [self initWithNodes:[NSSet set] edgeToRealEdge:[NSDictionary dictionary] nodeToEdgeSet:[NSDictionary dictionary]];
}

- (void)dealloc;
{
  OBJC_RELEASE(nodeToEdgeSet);
  OBJC_RELEASE(edgeToRealEdge);
  OBJC_RELEASE(nodes);
  [super dealloc];
}

- (id)clone;
{
  return [[[[self class] alloc] initWithNodes:nodes edgeToRealEdge:edgeToRealEdge nodeToEdgeSet:nodeToEdgeSet] autorelease];
}

- (NSSet*)nodes;
{
  return nodes;
}

- (void)addNode:(id)node;
{
  [nodes addObject:node];
  CFDictionarySetValue((CFMutableDictionaryRef)nodeToEdgeSet,node,[NSMutableSet set]);
}

- (void)removeNode:(id)node;
{
  [nodes removeObject:node];
  CFDictionaryRemoveValue((CFMutableDictionaryRef)nodeToEdgeSet,node);
}

- (BOOL)containsNode:(id)node;
{
  return [nodes containsObject:node];
}

- (NSSet*)predecessorsOfNode:(id)node;
{
  NSMutableSet* preds = [NSMutableSet set];
  NSEnumerator* edgesEnum = [[nodeToEdgeSet objectForKey:node] objectEnumerator];
  IFOrientedGraphEdge* edge;
  while (edge = [edgesEnum nextObject]) {
    if ([edge toNode] == node)
      [preds addObject:[edge fromNode]];
  }
  return preds;
}

- (NSSet*)successorsOfNode:(id)node;
{
  NSMutableSet* succs = [NSMutableSet set];
  NSEnumerator* edgesEnum = [[nodeToEdgeSet objectForKey:node] objectEnumerator];
  IFOrientedGraphEdge* edge;
  while (edge = [edgesEnum nextObject]) {
    if ([edge fromNode] == node)
      [succs addObject:[edge toNode]];
  }
  return succs;
}

- (NSSet*)sourceNodes;
{
  NSMutableSet* sourceNodes = [NSMutableSet setWithSet:nodes];
  NSEnumerator* nodesEnum = [nodeToEdgeSet keyEnumerator];
  id node;
  while (node = [nodesEnum nextObject]) {
    NSEnumerator* edgesEnum = [[nodeToEdgeSet objectForKey:node] objectEnumerator];
    IFOrientedGraphEdge* edge;
    while (edge = [edgesEnum nextObject]) {
      if ([edge fromNode] == node) {
        [sourceNodes removeObject:node];
        break;
      }
    }
  }
  return sourceNodes;
}

- (NSSet*)sinkNodes;
{
  NSMutableSet* sinkNodes = [NSMutableSet setWithSet:nodes];
  NSEnumerator* nodesEnum = [nodeToEdgeSet keyEnumerator];
  id node;
  while (node = [nodesEnum nextObject]) {
    NSEnumerator* edgesEnum = [[nodeToEdgeSet objectForKey:node] objectEnumerator];
    IFOrientedGraphEdge* edge;
    while (edge = [edgesEnum nextObject]) {
      if ([edge toNode] == node) {
        [sinkNodes removeObject:node];
        break;
      }
    }
  }
  return sinkNodes;
}

- (void)addEdge:(id)edge fromNode:(id)fromNode toNode:(id)toNode;
{
  IFOrientedGraphEdge* realEdge = [IFOrientedGraphEdge edgeFromNode:fromNode toNode:toNode data:edge];
  CFDictionarySetValue((CFMutableDictionaryRef)edgeToRealEdge,edge,realEdge);
  [[nodeToEdgeSet objectForKey:fromNode] addObject:realEdge];
  [[nodeToEdgeSet objectForKey:toNode] addObject:realEdge];
}

- (void)removeEdge:(id)edge;
{
  IFOrientedGraphEdge* realEdge = [edgeToRealEdge objectForKey:edge];
  [[nodeToEdgeSet objectForKey:[realEdge fromNode]] removeObject:realEdge];
  [[nodeToEdgeSet objectForKey:[realEdge toNode]] removeObject:realEdge];
  CFDictionaryRemoveValue((CFMutableDictionaryRef)edgeToRealEdge,edge);
}

- (BOOL)containsEdge:(id)edge;
{
  return [edgeToRealEdge objectForKey:edge] != nil;
}

- (id)edgeSource:(id)edge;
{
  IFOrientedGraphEdge* realEdge = [edgeToRealEdge objectForKey:edge];
  return [realEdge fromNode];
}

- (id)edgeTarget:(id)edge;
{
  IFOrientedGraphEdge* realEdge = [edgeToRealEdge objectForKey:edge];
  return [realEdge toNode];
}

- (NSSet*)allEdgesForNode:(id)node;
{
  return [nodeToEdgeSet objectForKey:node];
}

- (NSSet*)incomingEdgesForNode:(id)node;
{
  NSMutableSet* inEdges = [NSMutableSet set];
  NSEnumerator* edgesEnum = [[nodeToEdgeSet objectForKey:node] objectEnumerator];
  IFOrientedGraphEdge* edge;
  while (edge = [edgesEnum nextObject]) {
    if ([edge toNode] == node)
      [inEdges addObject:[edge data]];
  }
  return inEdges;
}

- (unsigned)inDegree:(id)node;
{
  return [[self incomingEdgesForNode:node] count];
}

- (NSSet*)outgoingEdgesForNode:(id)node;
{
  NSMutableSet* outEdges = [NSMutableSet set];
  NSEnumerator* edgesEnum = [[nodeToEdgeSet objectForKey:node] objectEnumerator];
  IFOrientedGraphEdge* edge;
  while (edge = [edgesEnum nextObject]) {
    if ([edge fromNode] == node)
      [outEdges addObject:[edge data]];
  }
  return outEdges;
}

- (unsigned)outDegree:(id)node;
{
  return [[self outgoingEdgesForNode:node] count];
}

- (NSArray*)topologicallySortedNodes;
{
  NSMutableArray* sortedNodes = [NSMutableArray arrayWithCapacity:[nodes count]];
  NSMutableSet* nodesToSort = [NSMutableSet setWithSet:nodes];
  while ([nodesToSort count] > 0) {
    id nextNode;
    NSEnumerator* nodesToSortEnum = [nodesToSort objectEnumerator];
    while (nextNode = [nodesToSortEnum nextObject]) {
      if (![nodesToSort intersectsSet:[self predecessorsOfNode:nextNode]])
        break;
    }
    if (nextNode == nil)
      return nil; // cyclic graph
    [sortedNodes addObject:nextNode];
    [nodesToSort removeObject:nextNode];
  }
  return sortedNodes;
}

- (BOOL)isCyclic;
{
  return [self topologicallySortedNodes] == nil;
}

@end

@implementation IFOrientedGraph (Private)

- (id)initWithNodes:(NSSet*)theNodes edgeToRealEdge:(NSDictionary*)theEdgeToRealEdge nodeToEdgeSet:(NSDictionary*)theNodeToEdgeSet;
{
  if (![super init])
    return nil;
  nodes = [[NSMutableSet setWithSet:theNodes] retain];

  NSEnumerator* keyEnum;
  id key;

  edgeToRealEdge = createMutableDictionaryWithRetainedKeys();
  keyEnum = [theEdgeToRealEdge keyEnumerator];
  while (key = [keyEnum nextObject])
    CFDictionarySetValue((CFMutableDictionaryRef)edgeToRealEdge,key,[theEdgeToRealEdge objectForKey:key]);
  
  nodeToEdgeSet = createMutableDictionaryWithRetainedKeys();
  keyEnum = [theNodeToEdgeSet keyEnumerator];
  while (key = [keyEnum nextObject])
    CFDictionarySetValue((CFMutableDictionaryRef)nodeToEdgeSet,key,[NSMutableSet setWithSet:[theNodeToEdgeSet objectForKey:key]]);

  return self;
}

@end
