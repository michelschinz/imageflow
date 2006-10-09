//
//  IFCacheingPolicyLRU.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFCacheingPolicyLRU : NSObject {
  int capacity, slack;
  NSMutableArray* sortedKeys;
  NSMutableSet* keysToRemove;
}

+ (id)cacheingPolicyWithCapacity:(int)theCapacity slack:(int)theSlack;
- (id)initWithCapacity:(int)theCapacity slack:(int)theSlack;

- (void)registerAccess:(NSObject*)key;
- (NSSet*)keysToRemove;
- (void)clearKeysToRemove;

@end
