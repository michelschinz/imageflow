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

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  static NSArray* types = nil;
  
  if (types == nil) {
    IFImageType* imageType = [IFImageType imageTypeWithPixelType:[IFTypeVar typeVarWithIndex:0]];
    types = [[NSArray arrayWithObject:[IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFArrayType arrayTypeWithContentType:imageType]] returnType:imageType]] retain];
  }
  return arity == 1 ? types : [NSArray array];
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
