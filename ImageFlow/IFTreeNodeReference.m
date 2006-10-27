//
//  IFTreeNodeReference.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeReference.h"


@implementation IFTreeNodeReference

+ (id)referenceWithTreeNode:(IFTreeNode*)theTreeNode;
{
  return [[[self alloc] initWithTreeNode:theTreeNode] autorelease];
}

- (id)initWithTreeNode:(IFTreeNode*)theTreeNode;
{
  if (![super init])
    return nil;
  treeNode = [theTreeNode retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(treeNode);
  [super dealloc];
}

- (IFTreeNode*)treeNode;
{
  return treeNode;
}

@end
