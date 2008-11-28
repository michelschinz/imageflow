//
//  IFMaskFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFMaskFilter.h"

#import "IFExpression.h"
#import "IFOperatorExpression.h"
#import "IFEnvironment.h"
#import "IFConstantExpression.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"

@implementation IFMaskFilter

static NSArray* parentNames = nil;
static NSArray* variantNames = nil;
static IFConstantExpression* maskColor = nil;

+ (void)initialize;
{
  if (self != [IFMaskFilter class])
    return; // avoid repeated initialisation

  parentNames = [[NSArray arrayWithObjects:@"image",@"mask",nil] retain];
  variantNames = [[NSArray arrayWithObjects:@"",@"overlay",nil] retain];
  maskColor = [[IFConstantExpression expressionWithColorNS:[NSColor colorWithCalibratedRed:1.0 green:0 blue:0 alpha:0.8]] retain];
}

- (NSArray*)potentialTypesForArity:(unsigned)arity;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObjects:[IFImageType imageRGBAType],[IFImageType maskType],nil]
                               returnType:[IFImageType imageRGBAType]]] retain];
  }
  return (arity == 2) ? types : [NSArray array];
}

- (NSArray*)potentialRawExpressionsForArity:(unsigned)arity;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"mask" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFParentExpression parentExpressionWithIndex:1],
      nil]] retain];
  }
  return (arity == 2) ? exprs : [NSArray array];
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [parentNames objectAtIndex:index];
}

- (NSString*)computeLabel;
{
  return @"mask";
}

- (NSString*)toolTip;
{
  return @"mask";
}

- (NSArray*)variantNamesForViewing;
{
  return variantNames;
}

- (NSArray*)variantNamesForEditing;
{
  return variantNames;
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  NSAssert1([variantName isEqualToString:@"overlay"], @"invalid variant name: <%@>", variantName);
  
  if ([originalExpression isKindOfClass:[IFOperatorExpression class]]) {
    IFOperatorExpression* originalOpExpression = (IFOperatorExpression*)originalExpression;
    NSAssert([originalOpExpression operator]  == [IFOperator operatorForName:@"mask"], @"unexpected operator");
    return [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"mask-overlay"]
                                               operands:[[originalOpExpression operands] arrayByAddingObject:maskColor]];
  } else
    return originalExpression;
}

@end
