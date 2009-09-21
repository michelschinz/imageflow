//
//  IFGaussianBlurFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFGaussianBlurFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFTypeVar.h"
#import "IFArgumentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"
#import "IFLambdaExpression.h"

@implementation IFGaussianBlurFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1) {
    IFImageType* imageType = [IFImageType imageTypeWithPixelType:[IFTypeVar typeVar]];
    return [NSArray arrayWithObject:
            [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:imageType]
                                     returnType:imageType]];
  } else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 1) {
    return [NSArray arrayWithObject:
            [IFLambdaExpression lambdaExpressionWithBody:
             [IFOperatorExpression expressionWithOperatorNamed:@"gaussian-blur" operands:
              [IFArgumentExpression argumentExpressionWithIndex:0],
              [IFVariableExpression expressionWithName:@"radius"],
              nil]]];
  } else {
    return [NSArray array];
  }
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"blur (%.1f gaussian)", [(NSNumber*)[settings valueForKey:@"radius"] floatValue]];
}

@end
