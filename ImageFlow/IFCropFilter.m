//
//  IFCropFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFCropFilter.h"

#import "IFEnvironment.h"
#import "IFAnnotationRect.h"
#import "IFVariableKVO.h"
#import "IFTreeNode.h"
#import "IFType.h"
#import "IFExpression.h"
#import "IFPrimitiveExpression.h"

@implementation IFCropFilter

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 1)
    return [NSArray arrayWithObject:[IFType funTypeWithArgumentType:[IFType imageRGBAType] returnType:[IFType imageRGBAType]]];
  else
    return [NSArray array];
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 1 && typeIndex == 0, @"invalid arity or type index");
  return [IFExpression lambdaWithBody:
          [IFExpression primitiveWithTag:IFPrimitiveTag_Crop operands:
           [IFExpression argumentWithIndex:0],
           [IFConstantExpression expressionWithObject:[settings valueForKey:@"rectangle"] tag:IFExpressionTag_Rect],
           nil]];
}

- (NSString*)computeLabel;
{
  NSRect r = [(NSValue*)[settings valueForKey:@"rectangle"] rectValue];
  return [NSString stringWithFormat:@"crop (%d,%d) %dx%d",
    (int)floor(NSMinX(r)),(int)floor(NSMinY(r)),(int)floor(NSWidth(r)),(int)floor(NSHeight(r))];
}

- (NSArray*)editingAnnotationsForView:(NSView*)view;
{
  IFVariable* src = [IFVariableKVO variableWithKVOCompliantObject:settings key:@"rectangle"];
  return [NSArray arrayWithObject:[IFAnnotationRect annotationRectWithView:view source:src]];
}

- (NSArray*)variantNamesForEditing;
{
  return [NSArray arrayWithObject:@"overlay"];
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  NSAssert1([variantName isEqualToString:@"overlay"], @"invalid variant name: %@", variantName);
  
  if ([originalExpression isKindOfClass:[IFPrimitiveExpression class]] && [(IFPrimitiveExpression*)originalExpression primitiveTag]  == IFPrimitiveTag_Crop)
    return [IFPrimitiveExpression primitiveWithTag:IFPrimitiveTag_CropOverlay operandsArray:[(IFPrimitiveExpression*)originalExpression operands]];
  else
    return originalExpression;
}

@end
