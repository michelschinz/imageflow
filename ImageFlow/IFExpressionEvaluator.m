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

@implementation IFExpressionEvaluator

static IFExpressionEvaluator* sharedEvaluator = nil;

+ (IFExpressionEvaluator*)sharedEvaluator;
{
  if (sharedEvaluator == nil)
    sharedEvaluator = [[self alloc] init];
  return sharedEvaluator;
}

- (id)init;
{
  if (![super init])
    return nil;
  caml_register_global_root(&cache);
  cache = caml_callback(*caml_named_value("Cache.make"), Val_int(100000000));
  return self;
}

- (void)dealloc;
{
  caml_remove_global_root(&cache);
  [super dealloc];
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
