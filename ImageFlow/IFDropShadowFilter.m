//
//  IFDropShadowFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFDropShadowFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"
#import "IFConstantExpression.h"
#import "IFBlendMode.h"

@implementation IFDropShadowFilter

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFImageType imageRGBAType]]] retain];
  }
  return (arity == 1) ? types : [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    IFExpression* sh = [IFOperatorExpression expressionWithOperatorNamed:@"single-color" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFVariableExpression expressionWithName:@"color"],
      nil];
    IFExpression* trSh = [IFOperatorExpression expressionWithOperatorNamed:@"translate" operands:sh,[IFVariableExpression expressionWithName:@"offset"], nil];
    IFExpression* blTrSh = [IFOperatorExpression expressionWithOperatorNamed:@"gaussian-blur" operands:trSh,[IFVariableExpression expressionWithName:@"blur"], nil];
    exprs = [[NSArray arrayWithObject:
      [IFOperatorExpression blendBackground:blTrSh
                             withForeground:[IFParentExpression parentExpressionWithIndex:0]
                                     inMode:[IFConstantExpression expressionWithInt:IFBlendMode_SourceOver]]] retain];
  }
  return (arity == 1) ? exprs : [NSArray array];
}

- (NSString*)computeLabel;
{
  return @"drop shadow";
}

@end
