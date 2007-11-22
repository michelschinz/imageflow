//
//  IFOrientedGraphEdge.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFOrientedGraphEdge.h"


@implementation IFOrientedGraphEdge

+ (id)edgeFromNode:(id)theFromNode toNode:(id)theToNode data:(id)theData;
{
  return [[[self alloc] initWithFromNode:theFromNode toNode:theToNode data:theData] autorelease];
}

- (id)initWithFromNode:(id)theFromNode toNode:(id)theToNode data:(id)theData;
{
  if (![super init])
    return nil;
  fromNode = [theFromNode retain];
  toNode = [theToNode retain];
  data = [theData retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(data);
  OBJC_RELEASE(toNode);
  OBJC_RELEASE(fromNode);
  [super dealloc];
}

- (id)fromNode;
{
  return fromNode;
}

- (id)toNode;
{
  return toNode;
}

- (id)data;
{
  return data;
}

#pragma mark NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithFromNode:[decoder decodeObjectForKey:@"fromNode"] toNode:[decoder decodeObjectForKey:@"toNode"] data:[decoder decodeObjectForKey:@"data"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeObject:fromNode forKey:@"fromNode"];
  [encoder encodeObject:toNode forKey:@"toNode"];
  [encoder encodeObject:data forKey:@"data"];
}

@end
