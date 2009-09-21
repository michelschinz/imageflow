//
//  IFInvertFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFInvertFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFLambdaExpression.h"
#import "IFArgumentExpression.h"
#import "IFParentExpression.h"
#import "IFOperatorExpression.h"
#import "IFLambdaExpression.h"

@implementation IFInvertFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return  [NSArray arrayWithObjects:
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
            [IFLambdaExpression lambdaExpressionWithBody:[IFOperatorExpression expressionWithOperatorNamed:@"invert" operands:[IFArgumentExpression argumentExpressionWithIndex:0],nil]],
            [IFLambdaExpression lambdaExpressionWithBody:[IFOperatorExpression expressionWithOperatorNamed:@"invert-mask" operands:[IFArgumentExpression argumentExpressionWithIndex:0],nil]],
            nil];
  } else {
    return [NSArray array];
  }
}

- (NSString*)computeLabel;
{
  return @"invert";
}

@end
