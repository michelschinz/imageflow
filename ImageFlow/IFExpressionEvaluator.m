//
//  IFExpressionEvaluator.m
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFExpressionEvaluator.h"


@implementation IFExpressionEvaluator

+ (IFConstantExpression*)invalidValue;
{
  static IFConstantExpression* invalidValue = nil;
  if (invalidValue == nil)
    invalidValue = [[IFConstantExpression expressionWithObject:@"<invalid_value>"] retain];
  return invalidValue;
}

- (id)init;
{
  if (![super init])
    return nil;
  workingColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  resolutionX = resolutionY = 300;
  return self;
}

- (void)dealloc;
{
  CGColorSpaceRelease(workingColorSpace);
  workingColorSpace = NULL;
  [super dealloc];
}

- (CGColorSpaceRef)workingColorSpace;
{
  return workingColorSpace;
}

- (void)setWorkingColorSpace:(CGColorSpaceRef)newWorkingColorSpace;
{
  if (newWorkingColorSpace == workingColorSpace)
    return;
  [self clearCache];
  CGColorSpaceRelease(workingColorSpace);
  workingColorSpace = CGColorSpaceRetain(newWorkingColorSpace);
}

- (float)resolutionX;
{
  return resolutionX;
}

- (void)setResolutionX:(float)newResolution;
{
  [self clearCache];
  resolutionX = newResolution;
}

- (float)resolutionY;
{
  return resolutionY;
}

- (void)setResolutionY:(float)newResolution;
{
  [self clearCache];
  resolutionY = newResolution;
}

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (BOOL)hasValue:(IFExpression*)expression;
{
  return [self evaluateExpression:expression] != [IFExpressionEvaluator invalidValue];
}

- (void)clearCache;
{
}

@end
