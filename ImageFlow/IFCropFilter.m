//
//  IFCropFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFCropFilter.h"

#import "IFOperatorExpression.h"
#import "IFEnvironment.h"
#import "IFAnnotationRect.h"
#import "IFVariableKVO.h"
#import "IFTreeNode.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"

@implementation IFCropFilter

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
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"crop" operands:
      [IFParentExpression parentExpressionWithIndex:0],
      [IFVariableExpression expressionWithName:@"rectangle"],
      nil]] retain];
  }
  return exprs;
}

- (NSString*)label;
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
  
  if ([originalExpression isKindOfClass:[IFOperatorExpression class]]
      && [(IFOperatorExpression*)originalExpression operator]  == [IFOperator operatorForName:@"crop"])
    return [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"crop-overlay"]
                                               operands:[(IFOperatorExpression*)originalExpression operands]];
  else
    return originalExpression;
}

@end
