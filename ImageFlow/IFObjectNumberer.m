//
//  IFObjectNumberer.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFObjectNumberer.h"


@implementation IFObjectNumberer

+ (id)numberer;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  if (![super init])
    return nil;
  objectToIndex = [[NSMutableDictionary dictionary] retain];
  freeIndices = [[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0,NSNotFound - 1)] retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(freeIndices);
  OBJC_RELEASE(objectToIndex);
  [super dealloc];
}

- (unsigned)uniqueNumberForObject:(id)object;
{
  NSValue* boxedObject = [NSValue valueWithPointer:object];
  NSNumber* objectNumber = [objectToIndex objectForKey:boxedObject];
  if (objectNumber != nil)
    return [objectNumber unsignedIntValue];
  unsigned index = [freeIndices firstIndex];
  [freeIndices removeIndex:index];
  [objectToIndex setObject:[NSNumber numberWithUnsignedInt:index] forKey:boxedObject];
  return index;
}

@end
