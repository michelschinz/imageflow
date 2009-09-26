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
#import "IFExpression.h"

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
            [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_Invert operand:[IFExpression argumentWithIndex:0]]],
            [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_InvertMask operand:[IFExpression argumentWithIndex:0]]],
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
