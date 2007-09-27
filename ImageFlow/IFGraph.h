//
//  IFGraph.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGraphNode.h"

@interface IFGraph : NSObject {
  NSMutableSet* nodes;
}

+ (id)graph;

- (void)addNode:(IFGraphNode*)newNode;
- (void)removeNode:(IFGraphNode*)node;

- (NSSet*)nodes;
- (IFGraphNode*)nodeWithData:(id)data;
- (NSArray*)topologicallySortedNodes;

- (BOOL)isTypeable;
- (NSDictionary*)resolveOverloading;
- (NSArray*)inferTypeForParamNodes:(NSArray*)paramNodes resultNode:(IFGraphNode*)resultNode;

@end
