//
//  IFExpressionEvaluator.h
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionVisitor.h"

@interface IFExpressionEvaluator : IFExpressionVisitor {
  CGColorSpaceRef workingColorSpace;
  float resolutionX, resolutionY;
  value cache;
}

+ (IFConstantExpression*)invalidValue;

- (CGColorSpaceRef)workingColorSpace;
- (void)setWorkingColorSpace:(CGColorSpaceRef)newWorkingColorSpace;

- (float)resolutionX;
- (void)setResolutionX:(float)newResolution;
- (float)resolutionY;
- (void)setResolutionY:(float)newResolution;

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
- (BOOL)hasValue:(IFExpression*)expression;

@end
