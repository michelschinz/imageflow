//
//  IFTreeEdge.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeEdge.h"


@implementation IFTreeEdge

+ (id)edgeWithTargetIndex:(unsigned)theTargetIndex;
{
  return [[[self alloc] initWithTargetIndex:theTargetIndex] autorelease];
}

- (id)initWithTargetIndex:(unsigned)theTargetIndex;
{
  if (![super init])
    return nil;
  targetIndex = theTargetIndex;
  return self;
}

- (IFTreeEdge*)clone;
{
  return [IFTreeEdge edgeWithTargetIndex:[self targetIndex]];
}

- (unsigned)targetIndex;
{
  return targetIndex;
}

#pragma NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithTargetIndex:[decoder decodeIntForKey:@"targetIndex"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeInt:targetIndex forKey:@"targetIndex"];
}

@end
