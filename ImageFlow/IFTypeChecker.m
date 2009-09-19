//
//  IFTypeChecker.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTypeChecker.h"

#import "IFType.h"

#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

static void camlInferTypes(int paramsCount, NSArray* dag, NSArray* types, NSArray** inferredTypes);
static value camlTypecheck(NSArray* dag, NSArray* potentialTypes);
static void camlConfigureDAG(NSArray* dag, NSArray* potentialTypes, NSArray** configuration);

@implementation IFTypeChecker

+ (IFTypeChecker*)sharedInstance;
{
  static IFTypeChecker* instance = nil;
  if (instance == nil)
    instance = [self new];
  return instance;
}

- (BOOL)checkDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
{
  return Bool_val(camlTypecheck(dag, potentialTypes));
}

- (NSArray*)configureDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
{
  NSArray* configuration;
  camlConfigureDAG(dag, potentialTypes, &configuration);
  return configuration;
}

@end

static value camlCons(value h, value t) {
  CAMLparam2(h,t);
  CAMLlocal1(cell);
  cell = caml_alloc(2, 0);
  Store_field(cell, 0, h);
  Store_field(cell, 1, t);
  CAMLreturn(cell);
}

static value dagToCaml(NSArray* dag) {
  CAMLparam0();
  CAMLlocal2(camlDAG, camlPreds);

  camlDAG = Val_int(0);
  for (int i = [dag count] - 1; i >= 0; --i) {
    NSArray* preds = [dag objectAtIndex:i];
    camlPreds = Val_int(0);
    for (int j = [preds count] - 1; j >= 0; --j) {
      int c = [[preds objectAtIndex:j] intValue];
      camlPreds = camlCons(Val_int(c), camlPreds);
    }
    camlDAG = camlCons(camlPreds, camlDAG);
  }
  CAMLreturn(camlDAG);
}

static value potentialTypesToCaml(NSArray* potentialTypes) {
  CAMLparam0();
  CAMLlocal2(camlPotentialTypes, camlTypes);
  
  camlPotentialTypes = Val_int(0);
  for (int i = [potentialTypes count] - 1; i >= 0; --i) {
    NSArray* types = [potentialTypes objectAtIndex:i];
    camlTypes = Val_int(0);
    for (int j = [types count] - 1; j >= 0; --j) {
      IFType* type = [types objectAtIndex:j];
      camlTypes = camlCons([type asCaml], camlTypes);
    }
    camlPotentialTypes = camlCons(camlTypes,camlPotentialTypes);
  }
  CAMLreturn(camlPotentialTypes);
}

static value camlTypecheck(NSArray* dag, NSArray* potentialTypes) {
  CAMLparam0();
  CAMLlocal2(camlDAG, camlPotentialTypes);
  
  camlDAG = dagToCaml(dag);
  camlPotentialTypes = potentialTypesToCaml(potentialTypes);
  
  static value* checkClosure = NULL;
  if (checkClosure == NULL)
    checkClosure = caml_named_value("Typechecker.check");
  
  CAMLreturn(caml_callback2(*checkClosure, camlDAG, camlPotentialTypes));
}

static void camlConfigureDAG(NSArray* dag, NSArray* potentialTypes, NSArray** configuration) {
  CAMLparam0();
  CAMLlocal5(camlDAG, camlTypes, camlConfigurationOption, camlConfiguration, camlPair);
  
  camlDAG = dagToCaml(dag);
  camlTypes = potentialTypesToCaml(potentialTypes);
  static value* configClosure = NULL;
  if (configClosure == NULL)
    configClosure = caml_named_value("Typechecker.first_valid_configuration");
  camlConfigurationOption = caml_callback2(*configClosure, camlDAG, camlTypes);

  if (camlConfigurationOption != Val_int(0)) {
    camlConfiguration = Field(camlConfigurationOption, 0);
    NSMutableArray* config = [NSMutableArray array];
    while (camlConfiguration != Val_int(0)) {
      camlPair = Field(camlConfiguration, 0);
      [config addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithInt:Int_val(Field(camlPair, 0))],
                         [IFType typeWithCamlType:Field(camlPair, 1)],
                         nil]];
      camlConfiguration = Field(camlConfiguration, 1);
    }
    *configuration = config;
  } else
    *configuration = nil;
  CAMLreturn0;
}
