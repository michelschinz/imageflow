//
//  IFTreeNodeParameter.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.02.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeNodeParameter.h"
#import "IFTypeVar.h"
#import "IFParentExpression.h"

@implementation IFTreeNodeParameter

+ (id)nodeParameterWithIndex:(int)index;
{
  return [[[self alloc] initWithIndex:index] autorelease];
}

- (id)initWithIndex:(int)theIndex;
{
  if (![super initWithFilter:nil])
    return nil;
  index = theIndex;
  return self;
}

- (IFTreeNode*)cloneNode;
{
  return [IFTreeNodeParameter nodeParameterWithIndex:index];
}

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil)
    types = [[NSArray arrayWithObject:[IFTypeVar typeVarWithIndex:0]] retain];
  return types;
}

- (void)setIndex:(int)newIndex;
{
  if (newIndex != index) {
    index = newIndex;
    [self updateExpression];
  }
}

- (int)index;
{
  return index;
}

- (void)updateExpression;
{
  [self setExpression:[IFParentExpression parentExpressionWithIndex:index]];
}

@end
