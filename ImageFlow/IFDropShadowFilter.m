//
//  IFDropShadowFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFDropShadowFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFArgumentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"
#import "IFConstantExpression.h"
#import "IFBlendMode.h"
#import "IFLambdaExpression.h"

@implementation IFDropShadowFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:
            [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                                     returnType:[IFImageType imageRGBAType]]];
  else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 1) {
    IFExpression* sh = [IFOperatorExpression expressionWithOperatorNamed:@"single-color" operands:
                        [IFArgumentExpression argumentExpressionWithIndex:0],
                        [IFVariableExpression expressionWithName:@"color"],
                        nil];
    IFExpression* trSh = [IFOperatorExpression expressionWithOperatorNamed:@"translate" operands:sh,[IFVariableExpression expressionWithName:@"offset"], nil];
    IFExpression* blTrSh = [IFOperatorExpression expressionWithOperatorNamed:@"gaussian-blur" operands:trSh,[IFVariableExpression expressionWithName:@"blur"], nil];
    
    return [NSArray arrayWithObject:
            [IFLambdaExpression lambdaExpressionWithBody:
             [IFOperatorExpression blendBackground:blTrSh
                                    withForeground:[IFArgumentExpression argumentExpressionWithIndex:0]
                                            inMode:[IFConstantExpression expressionWithInt:IFBlendMode_SourceOver]]]];
  } else {
    return [NSArray array];
  }
}

- (NSString*)computeLabel;
{
  return @"drop shadow";
}

@end
