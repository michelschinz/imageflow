//
//  IFAverageFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.06.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFAverageFilter.h"

#import "IFType.h"
#import "IFExpression.h"

@implementation IFAverageFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1) {
    IFType* imageType = [IFType imageTypeWithPixelType:[IFType typeVariable]];
    return [NSArray arrayWithObject:
            [IFType funTypeWithArgumentType:[IFType arrayTypeWithContentType:imageType]
                                 returnType:imageType]];
  } else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:[IFExpression primitiveWithTag:IFPrimitiveTag_Average operand:[IFExpression argumentWithIndex:0]]];
}

- (NSString*)computeLabel;
{
  return @"average";
}

@end
