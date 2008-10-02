//
//  IFThresholdFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFThresholdFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"

@implementation IFThresholdFilter

- (NSArray*)potentialTypes;
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
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObjects:
      [IFOperatorExpression expressionWithOperatorNamed:@"threshold" operands:
        [IFParentExpression parentExpressionWithIndex:0],
        [IFVariableExpression expressionWithName:@"threshold"],
        nil],
      [IFOperatorExpression expressionWithOperatorNamed:@"threshold-mask" operands:
        [IFParentExpression parentExpressionWithIndex:0],
        [IFVariableExpression expressionWithName:@"threshold"],
        nil],
      nil] retain];
  }
  return exprs;
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"threshold %.2f", [(NSNumber*)[settings valueForKey:@"threshold"] floatValue]];
}

@end
