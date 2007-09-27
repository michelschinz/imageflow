//
//  IFGraph.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFGraph.h"
#import "IFTypeChecker.h"

static NSArray* serialiseSortedNodes(NSArray* sortedNodes);

@implementation IFGraph

+ (id)graph;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  if (![super init])
    return nil;
  nodes = [[NSMutableSet set] retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(nodes);
  [super dealloc];
}

- (void)addNode:(IFGraphNode*)newNode;
{
  [nodes addObject:newNode];
}

- (void)removeNode:(IFGraphNode*)node;
{
  [nodes removeObject:node];
}

- (NSSet*)nodes;
{
  return nodes;
}

- (IFGraphNode*)nodeWithData:(id)data;
{
  NSEnumerator* nodesEnum = [nodes objectEnumerator];
  IFGraphNode* node;
  while (node = [nodesEnum nextObject])
    if ([node data] == data)
      return node;
  return nil;
}

- (NSArray*)topologicallySortedNodes;
{
  NSMutableArray* sortedNodes = [NSMutableArray arrayWithCapacity:[nodes count]];
  NSMutableSet* nodesToSort = [NSMutableSet setWithSet:nodes];
  while ([nodesToSort count] > 0) {
    IFGraphNode* nextNode;
    NSEnumerator* nodesToSortEnum = [nodesToSort objectEnumerator];
    while (nextNode = [nodesToSortEnum nextObject]) {
      if (![nodesToSort intersectsSet:[NSSet setWithArray:[nextNode predecessors]]])
        break;
    }
    if (nextNode == nil)
      return nil; // cyclic graph
    [sortedNodes addObject:nextNode];
    [nodesToSort removeObject:nextNode];
  }
  return sortedNodes;
}

- (BOOL)isTypeable;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  NSArray* sortedNodes = [self topologicallySortedNodes];
  NSAssert(sortedNodes != nil, @"attempt to type check a cyclic graph");
  return [typeChecker checkDAG:serialiseSortedNodes(sortedNodes) withPotentialTypes:[[sortedNodes collect] types]];
}

- (NSDictionary*)resolveOverloading;
{
  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  NSArray* sortedNodes = [self topologicallySortedNodes];
  const int nodesCount = [sortedNodes count];
  NSAssert(sortedNodes != nil, @"attempt to resolve overloading in a cyclic graph");
  NSArray* config = [typeChecker configureDAG:serialiseSortedNodes(sortedNodes) withPotentialTypes:[[sortedNodes collect] types]];
  NSMutableDictionary* configDict = createMutableDictionaryWithRetainedKeys();
  for (int i = 0; i < nodesCount; ++i)
    CFDictionarySetValue((CFMutableDictionaryRef)configDict, [sortedNodes objectAtIndex:i], [config objectAtIndex:i]);
  return configDict;
}

- (NSArray*)inferTypeForParamNodes:(NSArray*)paramNodes resultNode:(IFGraphNode*)resultNode;
{
  NSArray* sortedNodes = [self topologicallySortedNodes];
  NSAssert([sortedNodes lastObject] == resultNode, @"invalid result node");

  // re-sort nodes to put parameter nodes first, as required by the OCaml inference code
  NSMutableArray* resortedNodes = [NSMutableArray arrayWithCapacity:[sortedNodes count]];
  [resortedNodes addObjectsFromArray:paramNodes];
  NSSet* paramNodesSet = [NSSet setWithArray:paramNodes];
  for (int i = 0; i < [sortedNodes count]; ++i) {
    IFGraphNode* node = [sortedNodes objectAtIndex:i];
    if (![paramNodesSet containsObject:node])
      [resortedNodes addObject:node];
  }

  IFTypeChecker* typeChecker = [IFTypeChecker sharedInstance];
  return [typeChecker inferTypesForDAG:serialiseSortedNodes(resortedNodes) withPotentialTypes:[[resortedNodes collect] types] parametersCount:[paramNodes count]];
}

@end

static NSArray* serialiseSortedNodes(NSArray* sortedNodes)
{
  const int nodesCount = [sortedNodes count];
  NSMutableArray* serialisedNodes = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFGraphNode* node = [sortedNodes objectAtIndex:i];
    NSArray* preds = [node predecessors];
    const int predsCount = [preds count];
    NSMutableArray* serialisedPreds = [NSMutableArray arrayWithCapacity:predsCount];
    for (int j = 0; j < predsCount; ++j)
      [serialisedPreds addObject:[NSNumber numberWithInt:[sortedNodes indexOfObject:[preds objectAtIndex:j]]]];
    [serialisedNodes addObject:serialisedPreds];
  }
  return serialisedNodes;
}
