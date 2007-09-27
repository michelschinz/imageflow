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

static NSComparisonResult compareParamNodes(id n1, id n2, void* nothing) {
  int i1 = [n1 index], i2 = [n2 index];
  if (i1 < i2) return NSOrderedAscending;
  else if (i1 > i2) return NSOrderedDescending;
  else return NSOrderedSame;
}

- (NSArray*)potentialTypes;
{
  if (potentialTypes == nil) {
    IFGraph* graph = [[self root] graph];
    
    NSArray* allNodes = [[self root] dfsAncestors];
    NSMutableArray* paramNodes = [NSMutableArray array];
    for (int i = 0, count = [allNodes count]; i < count; ++i) {
      IFTreeNode* node = [allNodes objectAtIndex:i];
      if ([node isKindOfClass:[IFTreeNodeParameter class]])
        [paramNodes addObject:node];
    }
    [paramNodes sortUsingFunction:compareParamNodes context:nil];

    NSArray* paramGraphNodes = (NSArray*)[[graph collect] nodeWithData:[paramNodes each]];
    IFGraphNode* rootGraphNode = [graph nodeWithData:[self root]];
    potentialTypes = [[graph inferTypeForParamNodes:paramGraphNodes resultNode:rootGraphNode] retain];
  }
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
