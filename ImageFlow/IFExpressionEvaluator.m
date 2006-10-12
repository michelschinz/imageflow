//
//  IFExpressionEvaluator.m
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFExpressionEvaluator.h"

#import <caml/memory.h>
#import <caml/callback.h>

@interface IFExpressionEvaluator (Private)
- (void)clearCache;
@end

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
  caml_register_global_root(&cache);
  cache = caml_callback(*caml_named_value("Cache.make"), Val_int(100000000));
  return self;
}

- (void)dealloc;
{
  caml_remove_global_root(&cache);
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

static void camlEval(value cache, IFExpression* expression, IFConstantExpression** result) {
  CAMLparam1(cache);
  CAMLlocal2(camlExpr, camlRes);
  camlExpr = [expression asCaml];
  static value* evalClosure = NULL;
  if (evalClosure == NULL)
    evalClosure = caml_named_value("Optevaluator.eval");
  camlRes = caml_callback2(*evalClosure, cache, camlExpr);
  *result = [IFConstantExpression expressionWithCamlValue:camlRes];
  CAMLreturn0;
}

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
{
  IFConstantExpression* result = nil;
  camlEval(cache, expression, &result);
  return result;
}

- (BOOL)hasValue:(IFExpression*)expression;
{
  return [self evaluateExpression:expression] != [IFExpressionEvaluator invalidValue];
}

static void camlDelta(value cache, IFExpression* oldExpression, IFExpression* newExpression, NSRect* result) {
  CAMLparam1(cache);
  CAMLlocal3(camlOld, camlNew, camlRes);
  camlOld = [oldExpression asCaml];
  camlNew = [newExpression asCaml];
  static value* deltaClosure = NULL;
  if (deltaClosure == NULL)
    deltaClosure = caml_named_value("Delta.delta_array");
  CAMLlocalN(args, 3);
  args[0] = cache;
  args[1] = camlOld;
  args[2] = camlNew;
  camlRes = caml_callbackN(*deltaClosure, 3, args);
  *result = NSMakeRect(Double_field(camlRes, 0),
                       Double_field(camlRes, 1),
                       Double_field(camlRes, 2),
                       Double_field(camlRes, 3));
  CAMLreturn0;
}

- (NSRect)deltaFromOld:(IFExpression*)oldExpression toNew:(IFExpression*)newExpression;
{
  NSRect result = NSZeroRect;
  camlDelta(cache, oldExpression, newExpression, &result);
  return result;
}

@end

@implementation IFExpressionEvaluator (Private)

- (void)clearCache;
{
  // TODO
}

@end
