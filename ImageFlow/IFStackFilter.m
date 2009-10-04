//
//  IFStackFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFStackFilter.h"

#import "IFType.h"
#import "IFExpression.h"

@implementation IFStackFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  IFType* typeVar = [IFType typeVariable];
  IFType* retType = [IFType arrayTypeWithContentType:typeVar];
  if (arity == 0)
    return [NSArray arrayWithObject:retType];
  else {
    NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:arity];
    for (int i = 0; i < arity; ++i)
      [argTypes addObject:typeVar];
    IFType* argType = (arity == 1 ? [argTypes objectAtIndex:0] : [IFType tupleTypeWithComponentTypes:argTypes]);
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:argType returnType:retType]];
  }
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(typeIndex == 0, @"invalid arity or type index");

  NSMutableArray* operands = [NSMutableArray arrayWithCapacity:arity];
  for (unsigned i = 0; i < arity; ++i)
    [operands addObject:[IFExpression tupleGet:[IFExpression argumentWithIndex:0] index:i]];
  return [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_ArrayCreate operandsArray:operands]];
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [NSString stringWithFormat:@"#%d",index];
}

- (NSString*)computeLabel;
{
  return @"stack";
}

@end
