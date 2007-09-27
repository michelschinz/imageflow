//
//  IFGraphNode.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.09.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFGraphNode.h"


@implementation IFGraphNode

+ (id)graphNodeWithTypes:(NSArray*)theTypes data:(id)theData;
{
  return [[[self alloc] initWithTypes:theTypes data:theData] autorelease];
}

+ (id)graphNodeWithTypes:(NSArray*)theTypes;
{
  return [self graphNodeWithTypes:theTypes data:nil];
}

- (id)initWithTypes:(NSArray*)theTypes data:(id)theData;
{
  if (![super init])
    return nil;
  predecessors = [[NSMutableArray array] retain];
  types = [theTypes retain];
  data = theData;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(types);
  OBJC_RELEASE(predecessors);
  [super dealloc];
}

- (void)setPredecessors:(NSArray*)newPreds;
{
  [predecessors release];
  predecessors = [[NSMutableArray arrayWithArray:newPreds] retain];
}

- (NSArray*)predecessors;
{
  return predecessors;
}

- (void)addPredecessor:(IFGraphNode*)pred;
{
  [predecessors addObject:pred];
}

- (void)removeLastPredecessor;
{
  [predecessors removeLastObject];
}

- (void)replacePredecessor:(IFGraphNode*)oldPred byNode:(IFGraphNode*)newPred;
{
  for (int i = 0; i < [predecessors count]; ++i) {
    if ([predecessors objectAtIndex:i] == oldPred)
      [predecessors replaceObjectAtIndex:i withObject:newPred];
  }
}

- (NSArray*)types;
{
  return types;
}

- (id)data;
{
  return data;
}

@end
