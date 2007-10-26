//
//  IFTreeTemplate.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeTemplate.h"


@implementation IFTreeTemplate

+ (id)templateWithName:(NSString*)theName description:(NSString*)theDescription node:(IFTreeNode*)theNode;
{
  return [[[self alloc] initWithName:theName description:theDescription node:theNode] autorelease];
}

- (id)initWithName:(NSString*)theName description:(NSString*)theDescription node:(IFTreeNode*)theNode;
{
  if (![super init])
    return nil;
  name = [theName copy];
  description = [theDescription copy];
  node = [theNode retain];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(node);
  OBJC_RELEASE(description);
  OBJC_RELEASE(name);
  [super dealloc];
}

- (NSString*)name;
{
  return name;
}

- (NSString*)description;
{
  return description;
}

- (NSString*)comment;
{
  NSLog(@"obsolete method <comment>");
  return description;
}

- (IFTreeNode*)node;
{
  return node;
}

@end
