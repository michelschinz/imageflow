//
//  IFTreeNodeMacro.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeMacro.h"

#import "IFTreeNodeParameter.h"
#import "IFTypeChecker.h"

@implementation IFTreeNodeMacro

+ (id)nodeMacroWithRoot:(IFTreeNode*)theRoot inlineOnInsertion:(BOOL)theInlineOnInsertion;
{
  return [[[self alloc] initWithRoot:theRoot inlineOnInsertion:theInlineOnInsertion] autorelease];
}

- (id)initWithRoot:(IFTreeNode*)theRoot inlineOnInsertion:(BOOL)theInlineOnInsertion;
{
  if (![super init])
    return nil;
  inlineOnInsertion = theInlineOnInsertion;
  rootRef = [[IFTreeNodeReference referenceWithTreeNode:theRoot] retain];
  potentialTypes = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(potentialTypes);
  OBJC_RELEASE(rootRef);
  [super dealloc];
}

- (IFTreeNode*)cloneNode;
{
  return [IFTreeNodeMacro nodeMacroWithRoot:[self root] inlineOnInsertion:inlineOnInsertion];
}

- (NSArray*)potentialTypes;
{
  if (potentialTypes == nil)
    potentialTypes = [[[IFTypeChecker sharedInstance] inferTypeForTree:[self root]] retain];
  return potentialTypes;
}

- (BOOL)inlineOnInsertion;
{
  return inlineOnInsertion;
}

- (IFTreeNode*)root;
{
  return [rootRef treeNode];
}

- (void)updateExpression;
{
  // TODO plug parameters
  [self setExpression:[[self root] expression]];
}

@end
