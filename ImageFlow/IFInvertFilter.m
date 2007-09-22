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

@implementation IFInvertFilter

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
      [IFOperatorExpression expressionWithOperatorNamed:@"invert" operands:[IFParentExpression parentExpressionWithIndex:0],nil],
      [IFOperatorExpression expressionWithOperatorNamed:@"invert-mask" operands:[IFParentExpression parentExpressionWithIndex:0],nil],
      nil] retain];
  }
  return exprs;
}

- (NSString*)label;
{
  return @"invert";
}

@end
