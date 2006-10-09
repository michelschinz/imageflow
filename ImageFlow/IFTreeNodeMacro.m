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

static IFTreeNode* cloneNodesInSet(NSSet* nodes, IFTreeNode* root, int* parentsCount)
{
  if ([nodes containsObject:root]) {
    IFTreeNode* clonedRoot = [root shallowClone];
    NSArray* parents = [root parents];
    for (int i = 0; i < [parents count]; ++i)
      [clonedRoot insertObject:cloneNodesInSet(nodes, [parents objectAtIndex:i], parentsCount) inParentsAtIndex:i];
    return clonedRoot;
  } else
    return [IFTreeNodeParameter nodeParameterWithIndex:(*parentsCount)++];
}

+ (id)nodeMacroForExistingNodes:(NSSet*)nodes root:(IFTreeNode*)root;
{
  NSAssert([nodes containsObject:root], @"root not contained in nodes");
  int parentsCount = 0;
  return [self nodeMacroWithRoot:cloneNodesInSet(nodes, root, &parentsCount)];
}

+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot;
{
  return [[[self alloc] initWithRoot:theRoot] autorelease];
}

- (id)initWithRoot:(IFTreeNode*)theRoot;
{
  if (![super initWithFilter:[IFConfiguredFilter configuredFilterWithFilter:[IFFilterMacro filterWithMacroRoot:theRoot]
                                                                environment:[IFEnvironment environment]]])
    return nil;
  root = [theRoot retain];
  return self;
}

- (void)dealloc;
{
  [root release];
  root = nil;
  [super dealloc];
}

- (IFTreeNode*)shallowClone;
{
  return [IFTreeNodeMacro nodeMacroWithRoot:root];
}

- (IFTreeNode*)root;
{
  return root;
}

@end
