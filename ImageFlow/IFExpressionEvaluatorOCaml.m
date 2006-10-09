//
//  IFExpressionEvaluatorOCaml.m
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFExpressionEvaluatorOCaml.h"

#import <caml/memory.h>
#import <caml/callback.h>

@implementation IFExpressionEvaluatorOCaml

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

static void camlEval(value cache, IFExpression* expression, IFConstantExpression** result) {
  CAMLparam0();
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

@end
