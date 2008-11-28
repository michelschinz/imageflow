//
//  IFColorControlsFilter.m
//  ImageFlow
//
//  Created by Olivier Crameri on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFColorControlsFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"

@implementation IFColorControlsFilter

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
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"color-controls" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFVariableExpression expressionWithName:@"contrast"],
      [IFVariableExpression expressionWithName:@"brightness"],
      [IFVariableExpression expressionWithName:@"saturation"],
      nil]] retain];
  }
  return (arity == 1) ? exprs : [NSArray array];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"control colors"];
}

@end
