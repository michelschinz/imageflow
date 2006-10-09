//
//  IFObjectNamer.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFObjectNamer.h"


@implementation IFObjectNamer

- (id)init;
{
  if (![super init])
    return nil;
  nameToObject = [NSMutableDictionary new];
  objectToName = [NSMutableDictionary new];
  return self;
}

- (void) dealloc;
{
  [objectToName release];
  objectToName = nil;
  [nameToObject release];
  nameToObject = nil;
  [super dealloc];
}

- (void)registerObject:(NSObject*)object nameHint:(NSString*)nameHint;
{
  NSString* name = nameHint;
  if ([nameToObject objectForKey:name] != nil) {
    int counter = 2;
    do {
      name = [NSString stringWithFormat:@"%@ [%d]",nameHint,counter++];
    } while ([nameToObject objectForKey:name] != nil);
  }
  NSAssert([nameToObject objectForKey:name] == nil, @"non-unique name generated");
  [nameToObject setObject:object forKey:name];
  [objectToName setObject:name forKey:[NSValue valueWithPointer:object]];
}

- (NSString*)uniqueNameForObject:(id)object;
{
  return [objectToName objectForKey:[NSValue valueWithPointer:object]];
}

- (id)objectForUniqueName:(NSString*)name;
{
  return [nameToObject objectForKey:name];
}

@end
