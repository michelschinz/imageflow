//
//  IFExpressionEvaluator.h
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConstantExpression.h"

@interface IFExpressionEvaluator : NSObject {
  CGColorSpaceRef workingColorSpace;
  value cache;
}

+ (IFExpressionEvaluator*)sharedEvaluator;

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
- (NSRect)deltaFromOld:(IFExpression*)oldExpression toNew:(IFExpression*)newExpression;

@end
