//
//  IFTreeNodeMacro.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeMacro.h"

#import "IFFilterMacro.h"
#import "IFTreeNodeParameter.h"

@implementation IFTreeNodeMacro

+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot;
{
  return [[[self alloc] initWithRoot:theRoot] autorelease];
}

- (id)initWithRoot:(IFTreeNode*)theRoot;
{
  IFTreeNodeReference* rootReference = [IFTreeNodeReference referenceWithTreeNode:theRoot];
  if (![super initWithFilter:[IFConfiguredFilter configuredFilterWithFilter:[IFFilterMacro filterWithMacroRootReference:rootReference]
                                                                environment:[IFEnvironment environment]]])
    return nil;
  rootRef = [rootReference retain];
  return self;
}

- (void)dealloc;
{
  [rootRef release];
  rootRef = nil;
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  return [IFTreeNodeMacro nodeMacroWithRoot:[self root]];
}

- (void)unlinkTree;
{
  NSAssert(NO, @"TODO");
  // TODO clone tree deeply, and make sure that clients are informed of the change
}

- (IFTreeNode*)root;
{
  return [rootRef treeNode];
}

@end
