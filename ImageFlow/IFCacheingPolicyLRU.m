//
//  IFCacheingPolicyLRU.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFCacheingPolicyLRU.h"


@implementation IFCacheingPolicyLRU

+ (id)cacheingPolicyWithCapacity:(int)theCapacity slack:(int)theSlack;
{
  return [[[self alloc] initWithCapacity:theCapacity slack:theSlack] autorelease];
}

- (id)initWithCapacity:(int)theCapacity slack:(int)theSlack;
{
  if (![super init])
    return nil;
  capacity = theCapacity;
  slack = theSlack;
  sortedKeys = [[NSMutableArray alloc] initWithCapacity:theCapacity+1];
  keysToRemove = [NSMutableSet new];
  return self;
}

- (void) dealloc;
{
  [keysToRemove release];
  keysToRemove = nil;
  [sortedKeys release];
  sortedKeys = nil;
  [super dealloc];
}

- (void)registerAccess:(NSObject*)key;
{
  [sortedKeys removeObject:key];
  [sortedKeys insertObject:key atIndex:0];
  if ([sortedKeys count] > capacity + slack) {
    do {
      [keysToRemove addObject:[sortedKeys lastObject]];
      [sortedKeys removeLastObject];
    } while ([sortedKeys count] > capacity);
  }
}

- (NSSet*)keysToRemove;
{
  return [[keysToRemove copy] autorelease];
}

- (void)clearKeysToRemove;
{
  [keysToRemove removeAllObjects];
}

@end
