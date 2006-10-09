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
#import "IFAnnotationSourceEnvironment.h"
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
  IFAnnotationSource* src = [IFAnnotationSourceEnvironment annotationSourceWithEnvironment:env
                                                                              variableName:@"rectangle"];
  return [NSArray arrayWithObject:[IFAnnotationRect annotationRectWithView:view source:src]];
}

- (NSArray*)variantNamesForEditing;
{
  return [NSArray arrayWithObject:@"Image+Mask"];
}

- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;
{
  NSAssert1([variantName isEqualToString:@"Image+Mask"], @"invalid variant name: %@", variantName);
  
  if ([originalExpression isKindOfClass:[IFOperatorExpression class]]) {
    IFOperatorExpression* originalOpExpression = (IFOperatorExpression*)originalExpression;
    NSAssert([originalOpExpression operator]  == [IFOperator operatorForName:@"crop"], @"unexpected operator");
    return [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"crop-overlay"]
                                               operands:[originalOpExpression operands]];
  } else
    return originalExpression;
}

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;
{
  return [NSAffineTransform transform];
}

@end
