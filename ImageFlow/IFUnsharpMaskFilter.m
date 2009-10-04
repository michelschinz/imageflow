//
//  IFUnsharpMaskFilter.m
//  ImageFlow
//
//  Created by Renault John on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFUnsharpMaskFilter.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFUnsharpMaskFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:
            [IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType imageRGBAType]]];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  
  return [IFExpression lambdaWithBody:
          [IFExpression primitiveWithTag:IFPrimitiveTag_UnsharpMask operands:
           [IFExpression argumentWithIndex:0],
           [IFConstantExpression expressionWithObject:[settings valueForKey:@"intensity"] tag:IFExpressionTag_Num],
           [IFConstantExpression expressionWithObject:[settings valueForKey:@"radius"] tag:IFExpressionTag_Num],
           nil]];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"USM (%.1f int, %.1f rad)", [(NSNumber*)[settings valueForKey:@"intensity"] floatValue], [(NSNumber*)[settings valueForKey:@"radius"] floatValue]];
}

@end
