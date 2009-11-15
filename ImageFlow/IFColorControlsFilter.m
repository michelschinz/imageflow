//
//  IFColorControlsFilter.m
//  ImageFlow
//
//  Created by Olivier Crameri on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFColorControlsFilter.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFColorControlsFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType imageRGBAType]]];
  else
    return [NSArray array];
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:
          [IFExpression primitiveWithTag:IFPrimitiveTag_ColorControls operands:
           [IFExpression argumentWithIndex:0],
           [IFConstantExpression expressionWithWrappedFloat:[settings valueForKey:@"contrast"]],
           [IFConstantExpression expressionWithWrappedFloat:[settings valueForKey:@"brightness"]],
           [IFConstantExpression expressionWithWrappedFloat:[settings valueForKey:@"saturation"]],
           nil]];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"control colors"];
}

@end
