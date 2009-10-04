//
//  IFDropShadowFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFDropShadowFilter.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"
#import "IFConstantExpression.h"
#import "IFBlendMode.h"

@implementation IFDropShadowFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType imageRGBAType]]];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  IFExpression* sh = [IFExpression primitiveWithTag:IFPrimitiveTag_SingleColor operands:
                      [IFExpression argumentWithIndex:0],
                      [IFConstantExpression expressionWithObject:[settings valueForKey:@"color"] tag:IFExpressionTag_Color],
                      nil];
  IFExpression* trSh = [IFExpression primitiveWithTag:IFPrimitiveTag_Translate operands:sh, [IFConstantExpression expressionWithObject:[settings valueForKey:@"offset"] tag:IFExpressionTag_Point], nil];
  IFExpression* blTrSh = [IFExpression primitiveWithTag:IFPrimitiveTag_GaussianBlur operands:trSh, [IFConstantExpression expressionWithObject:[settings valueForKey:@"blur"] tag:IFExpressionTag_Num], nil];
    
  return [IFExpression lambdaWithBody:
          [IFExpression blendBackground:blTrSh
                         withForeground:[IFExpression argumentWithIndex:0]
                                 inMode:[IFConstantExpression expressionWithInt:IFBlendMode_SourceOver]]];
}

- (NSString*)computeLabel;
{
  return @"drop shadow";
}

@end
