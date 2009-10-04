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

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 1) {
    return [NSArray arrayWithObject:
            [IFExpression lambdaWithBody:
             [IFExpression primitiveWithTag:IFPrimitiveTag_ColorControls operands:
              [IFExpression argumentWithIndex:0],
              [IFConstantExpression expressionWithObject:[settings valueForKey:@"contrast"] tag:IFExpressionTag_Num],
              [IFConstantExpression expressionWithObject:[settings valueForKey:@"brightness"] tag:IFExpressionTag_Num],
              [IFConstantExpression expressionWithObject:[settings valueForKey:@"saturation"] tag:IFExpressionTag_Num],
              nil]]];
  } else {
    return [NSArray array];
  }
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"control colors"];
}

@end
