//
//  IFUnsharpMaskFilter.m
//  ImageFlow
//
//  Created by Renault John on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFUnsharpMaskFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFArgumentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"
#import "IFLambdaExpression.h"

@implementation IFUnsharpMaskFilter

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
    return [NSArray arrayWithObject:
            [IFLambdaExpression lambdaExpressionWithBody:
             [IFOperatorExpression expressionWithOperatorNamed:@"unsharp-mask" operands:
              [IFArgumentExpression argumentExpressionWithIndex:0],
              [IFVariableExpression expressionWithName:@"intensity"],
              [IFVariableExpression expressionWithName:@"radius"],
              nil]]];
  } else {
    return [NSArray array];
  }
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"USM (%.1f int, %.1f rad)", [(NSNumber*)[settings valueForKey:@"intensity"] floatValue], [(NSNumber*)[settings valueForKey:@"radius"] floatValue]];
}

@end
