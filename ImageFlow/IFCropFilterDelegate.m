//
//  IFCropFilterDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFCropFilterDelegate.h"

#import "IFOperatorExpression.h"
#import "IFEnvironment.h"
#import "IFAnnotationRect.h"
#import "IFVariableKVO.h"
#import "IFTreeNode.h"

@implementation IFCropFilterDelegate

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  NSRect r = [(NSValue*)[env valueForKey:@"rectangle"] rectValue];
  return [NSString stringWithFormat:@"crop (%d,%d) %dx%d",
    (int)floor(NSMinX(r)),(int)floor(NSMinY(r)),(int)floor(NSWidth(r)),(int)floor(NSHeight(r))];
}

- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view;
{
  IFEnvironment* env = [[node filter] environment];
  IFVariable* src = [IFVariableKVO variableWithKVOCompliantObject:env key:@"rectangle"];
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
