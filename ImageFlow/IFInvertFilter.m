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
#import "IFParentExpression.h"
#import "IFOperatorExpression.h"

@implementation IFInvertFilter

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObjects:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFImageType imageRGBAType]],
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType maskType]]
                               returnType:[IFImageType maskType]],
      nil] retain];      
  }
  return (arity == 1) ? types : [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObjects:
      [IFOperatorExpression expressionWithOperatorNamed:@"invert" operands:[IFParentExpression parentExpressionWithIndex:0],nil],
      [IFOperatorExpression expressionWithOperatorNamed:@"invert-mask" operands:[IFParentExpression parentExpressionWithIndex:0],nil],
      nil] retain];
  }
  return (arity == 1) ? exprs : [NSArray array];
}

- (NSString*)computeLabel;
{
  return @"invert";
}

@end
