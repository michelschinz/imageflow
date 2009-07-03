//
//  IFAverageFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.06.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFAverageFilter.h"

#import "IFImageType.h"
#import "IFFunType.h"
#import "IFArrayType.h"
#import "IFTypeVar.h"
#import "IFOperatorExpression.h"
#import "IFParentExpression.h"

@implementation IFAverageFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1) {
    IFImageType* imageType = [IFImageType imageTypeWithPixelType:[IFTypeVar typeVar]];
    return [NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFArrayType arrayTypeWithContentType:imageType]] returnType:imageType]];
  } else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  static NSArray* exprs = nil;
  
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"average"] operands:[NSArray arrayWithObject:[IFParentExpression parentExpressionWithIndex:0]]]] retain];
  }
  
  return arity == 1 ? exprs : [NSArray array];
}

- (NSString*)computeLabel;
{
  return @"average";
}

@end
