//
//  IFUnsharpMaskFilter.m
//  ImageFlow
//
//  Created by Renault John on 19.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IFUnsharpMaskFilter.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"
#import "IFOperatorExpression.h"

@implementation IFUnsharpMaskFilter

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFImageType imageRGBAType]]] retain];
  }
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"unsharp-mask" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFVariableExpression expressionWithName:@"intensity"],
      [IFVariableExpression expressionWithName:@"radius"],
      nil]] retain];
  }
  return exprs;
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"USM (%.1f int, %.1f rad)", [(NSNumber*)[settings valueForKey:@"intensity"] floatValue], [(NSNumber*)[settings valueForKey:@"radius"] floatValue]];
}

@end
