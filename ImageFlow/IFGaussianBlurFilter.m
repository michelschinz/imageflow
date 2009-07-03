//
//  IFGaussianBlurFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFGaussianBlurFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFTypeVar.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"

@implementation IFGaussianBlurFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1) {
    IFImageType* imageType = [IFImageType imageTypeWithPixelType:[IFTypeVar typeVar]];
    return [NSArray arrayWithObject:
            [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:imageType]
                                     returnType:imageType]];
  } else
    return [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"gaussian-blur" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFVariableExpression expressionWithName:@"radius"],
      nil]] retain];
  }
  return (arity == 1) ? exprs : [NSArray array];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"blur (%.1f gaussian)", [(NSNumber*)[settings valueForKey:@"radius"] floatValue]];
}

@end
