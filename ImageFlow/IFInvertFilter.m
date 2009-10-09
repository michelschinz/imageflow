//
//  IFInvertFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFInvertFilter.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFInvertFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return  [NSArray arrayWithObjects:
             [IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType imageRGBAType]],
             [IFType funTypeWithArgumentType:[IFType maskType] returnType:[IFType maskType]],
             nil];
  else
    return [NSArray array];
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex <= 1, @"invalid arity or type index");

  if (typeIndex == 0)
    return [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_Invert operand:[IFExpression argumentWithIndex:0]]];
  else
    return [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_InvertMask operand:[IFExpression argumentWithIndex:0]]];
}

- (NSString*)computeLabel;
{
  return @"invert";
}

@end
