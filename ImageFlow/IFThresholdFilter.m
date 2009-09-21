//
//  IFThresholdFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFThresholdFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFArgumentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"
#import "IFLambdaExpression.h"

@implementation IFThresholdFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObjects:
            [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                                     returnType:[IFImageType imageRGBAType]],
            [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType maskType]]
                                     returnType:[IFImageType maskType]],
            nil];
  else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 1) {
    return [NSArray arrayWithObjects:
            [IFLambdaExpression lambdaExpressionWithBody:
             [IFOperatorExpression expressionWithOperatorNamed:@"threshold" operands:
              [IFArgumentExpression argumentExpressionWithIndex:0],
              [IFVariableExpression expressionWithName:@"threshold"],
              nil]],
            [IFLambdaExpression lambdaExpressionWithBody:
             [IFOperatorExpression expressionWithOperatorNamed:@"threshold-mask" operands:
              [IFArgumentExpression argumentExpressionWithIndex:0],
              [IFVariableExpression expressionWithName:@"threshold"],
              nil]],
            nil];
  } else {
    return [NSArray array];
  }
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"threshold %.2f", [(NSNumber*)[settings valueForKey:@"threshold"] floatValue]];
}

@end
