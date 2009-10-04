//
//  IFMaskFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFMaskFilter.h"

#import "IFExpression.h"
#import "IFConstantExpression.h"
#import "IFPrimitiveExpression.h"
#import "IFEnvironment.h"
#import "IFType.h"

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

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 2)
    return [NSArray arrayWithObject:
            [IFType funTypeWithArgumentType:[IFType tupleTypeWithComponentTypes:[NSArray arrayWithObjects:[IFType imageRGBAType],[IFType maskType],nil]]
                                 returnType:[IFType imageRGBAType]]];
  else
    return [NSArray array];
}

- (IFExpression*)potentialRawExpressionsForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 2 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:
          [IFExpression primitiveWithTag:IFPrimitiveTag_Mask operands:
           [IFExpression tupleGet:[IFExpression argumentWithIndex:0] index:0],
           [IFExpression tupleGet:[IFExpression argumentWithIndex:0] index:1],
           nil]];
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
  
  if ([originalExpression isKindOfClass:[IFPrimitiveExpression class]]) {
    IFPrimitiveExpression* originalOpExpression = (IFPrimitiveExpression*)originalExpression;
    NSAssert([originalOpExpression tag]  == IFPrimitiveTag_Mask, @"unexpected operator");
    return [IFExpression primitiveWithTag:IFPrimitiveTag_MaskOverlay operandsArray:[[originalOpExpression operands] arrayByAddingObject:maskColor]];
  } else
    return originalExpression;
}

@end
