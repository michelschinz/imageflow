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

+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot inlineOnInsertion:(BOOL)theInlineOnInsertion;
{
  return [[[self alloc] initWithRoot:theRoot inlineOnInsertion:theInlineOnInsertion] autorelease];
}

- (id)initWithRoot:(IFTreeNode*)theRoot inlineOnInsertion:(BOOL)theInlineOnInsertion;
{
  IFTreeNodeReference* rootReference = [IFTreeNodeReference referenceWithTreeNode:theRoot];
  if (![super initWithFilter:[IFConfiguredFilter configuredFilterWithFilter:[IFFilterMacro filterWithMacroRootReference:rootReference]
                                                                environment:[IFEnvironment environment]]])
    return nil;
  inlineOnInsertion = theInlineOnInsertion;
  rootRef = [rootReference retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(rootRef);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  return [IFTreeNodeMacro nodeMacroWithRoot:[self root] inlineOnInsertion:inlineOnInsertion];
}

- (BOOL)inlineOnInsertion;
{
  return inlineOnInsertion;
}

- (IFTreeNode*)root;
{
  return [rootRef treeNode];
}

- (void)unlinkTree;
{
  NSAssert(NO, @"TODO");
  // TODO clone tree deeply, and make sure that clients are informed of the change
}

@end
