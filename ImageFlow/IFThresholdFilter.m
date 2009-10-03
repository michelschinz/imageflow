//
//  IFThresholdFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFThresholdFilter.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@implementation IFThresholdFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObjects:
            [IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType imageRGBAType]],
            [IFType funTypeWithArgumentType:[IFType maskType] returnType:[IFType maskType]],
            nil];
  else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  if (arity == 1) {
    return [NSArray arrayWithObjects:
            [IFExpression lambdaWithBody:
             [IFExpression primitiveWithTag:IFPrimitiveTag_Threshold operands:
              [IFExpression argumentWithIndex:0],
              [IFExpression variableWithName:@"threshold"],
              nil]],
            [IFExpression lambdaWithBody:
             [IFExpression primitiveWithTag:IFPrimitiveTag_ThresholdMask operands:
              [IFExpression argumentWithIndex:0],
              [IFExpression variableWithName:@"threshold"],
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
