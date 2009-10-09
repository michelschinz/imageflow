//
//  IFGhostFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFGhostFilter.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFGhostFilter

- (BOOL)isGhost;
{
  return YES;
}

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObject:[IFType typeVariable]];
  else {
    NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:arity];
    for (int i = 0; i < arity; ++i)
      [argTypes addObject:[IFType typeVariable]];
    IFType* argType = (arity == 1 ? [argTypes objectAtIndex:0] : [IFType tupleTypeWithComponentTypes:argTypes]);
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:argType returnType:[IFType typeVariable]]];
  }
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(typeIndex == 0, @"invalid type index");
  if (arity == 0)
    return [IFExpression fail];
  else
    return [IFExpression lambdaWithBody:[IFExpression fail]];
}

- (NSString*)computeLabel;
{
  return @"";
}

@end
