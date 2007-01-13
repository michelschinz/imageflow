//
//  IFMaskFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFMaskFilterDelegate.h"

#import "IFExpression.h"
#import "IFOperatorExpression.h"
#import "IFEnvironment.h"
#import "IFConstantExpression.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"

@implementation IFMaskFilterDelegate

static NSArray* parentNames = nil;
static NSArray* variantNames = nil;
static IFConstantExpression* maskColor = nil;

+ (void)initialize;
{
  if (self != [IFMaskFilterDelegate class])
    return; // avoid repeated initialisation

  parentNames = [[NSArray arrayWithObjects:@"image",@"mask",nil] retain];
  variantNames = [[NSArray arrayWithObjects:@"",@"overlay",nil] retain];
  maskColor = [[IFConstantExpression expressionWithColorNS:[NSColor colorWithCalibratedRed:1.0 green:0 blue:0 alpha:0.8]] retain];
}

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObjects:[IFImageType imageRGBAType],[IFImageType maskType],nil]
                               returnType:[IFImageType imageRGBAType]]] retain];
  }
  return types;
}

- (NSString*)nameOfParentAtIndex:(int)index;
{
  return [parentNames objectAtIndex:index];
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return @"mask";
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
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
