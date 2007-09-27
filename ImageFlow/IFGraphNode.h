//
//  IFGraphNode.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFGraphNode : NSObject {
  NSMutableArray* predecessors;
  NSArray* types;
  id data; // not retained
}

+ (id)graphNodeWithTypes:(NSArray*)theTypes data:(id)theData;
+ (id)graphNodeWithTypes:(NSArray*)theTypes;
- (id)initWithTypes:(NSArray*)theTypes data:(id)theData;

- (void)setPredecessors:(NSArray*)newPreds;
- (NSArray*)predecessors;
- (void)addPredecessor:(IFGraphNode*)pred;
- (void)removeLastPredecessor;
- (void)replacePredecessor:(IFGraphNode*)oldPred byNode:(IFGraphNode*)newPred;

- (NSArray*)types;
- (id)data;

@end
