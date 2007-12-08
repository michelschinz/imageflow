//
//  IFExpressionEvaluator.m
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFExpressionEvaluator.h"

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

@interface IFExpressionEvaluator (Private)
- (void)clearCache;
@end

@implementation IFExpressionEvaluator

- (id)init;
{
  if (![super init])
    return nil;
  workingColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
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

static void camlEval(value* closurePtr, value cache, IFExpression* expression, IFConstantExpression** result) {
  CAMLparam1(cache);
  CAMLlocal2(camlExpr, camlRes);
  camlExpr = [expression asCaml];
  camlRes = caml_callback2(*closurePtr, cache, camlExpr);
  *result = [IFConstantExpression expressionWithCamlValue:camlRes];
  CAMLreturn0;
}

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
{
  static value* closurePtr = NULL;
  if (closurePtr == NULL)
    closurePtr = caml_named_value("Optevaluator.eval");
  IFConstantExpression* result = nil;
  camlEval(closurePtr, cache, expression, &result);
  return result;
}

- (IFConstantExpression*)evaluateExpressionAsImage:(IFExpression*)expression;
{
  static value* closurePtr = NULL;
  if (closurePtr == NULL)
    closurePtr = caml_named_value("Optevaluator.eval_as_image");
  IFConstantExpression* result = nil;
  camlEval(closurePtr, cache, expression, &result);
  return result;
}

static value camlRect(NSRect r) {
  CAMLparam0();
  CAMLlocalN(args, 4);
  static value* rectMakeClosure = NULL;
  if (rectMakeClosure == NULL)
    rectMakeClosure = caml_named_value("Rect.make");
  args[0] = caml_copy_double(NSMinX(r));
  args[1] = caml_copy_double(NSMinY(r));
  args[2] = caml_copy_double(NSWidth(r));
  args[3] = caml_copy_double(NSHeight(r));
  CAMLreturn(caml_callbackN(*rectMakeClosure, 4, args));
}  

static void camlEvalAsMaskedImage(value cache, IFExpression* expression, NSRect cutoutRect, IFConstantExpression** result) {
  CAMLparam1(cache);
  CAMLlocal3(camlExpr, camlCutoutRect, camlRes);
  static value* evalClosure = NULL;
  if (evalClosure == NULL)
    evalClosure = caml_named_value("Optevaluator.eval_as_masked_image");
  camlExpr = [expression asCaml];
  camlCutoutRect = camlRect(cutoutRect);
  camlRes = caml_callback3(*evalClosure, cache, camlExpr, camlCutoutRect);
  *result = [IFConstantExpression expressionWithCamlValue:camlRes];
  CAMLreturn0;
}

- (IFConstantExpression*)evaluateExpressionAsMaskedImage:(IFExpression*)expression cutout:(NSRect)cutoutRect;
{
  IFConstantExpression* result = nil;
  camlEvalAsMaskedImage(cache, expression, cutoutRect, &result);
  return result;
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
