//
//  IFTreeTemplate.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeTemplate.h"


@implementation IFTreeTemplate

+ (id)templateWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;
{
  return [[[self alloc] initWithName:theName description:theDescription tree:theTree] autorelease];
}

- (id)initWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;
{
  if (![super init])
    return nil;
  name = [theName copy];
  description = [theDescription copy];
  tree = [theTree retain];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(tree);
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

- (IFTree*)tree;
{
  return tree;
}

- (IFTreeNode*)node;
{
  return [tree root];
}

@end
