//
//  IFTypeChecker.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTypeChecker.h"

#import "IFTreeNodeParameter.h"
#import <caml/memory.h>
#import <caml/alloc.h>
#import <caml/callback.h>

static void camlInferTypesForTree(int paramsCount, NSArray* dag, NSArray* types, NSArray** inferredTypes);
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

static NSComparisonResult compareParamNodes(id n1, id n2, void* nothing) {
  int i1 = [n1 index], i2 = [n2 index];
  if (i1 < i2) return NSOrderedAscending;
  else if (i1 > i2) return NSOrderedDescending;
  else return NSOrderedSame;
}

- (NSArray*)inferTypeForTree:(IFTreeNode*)root;
{
  NSArray* allNodes = [root topologicallySortedAncestorsWithoutAliases];
  
  NSMutableArray* paramNodes = [NSMutableArray array];
  NSMutableArray* nonParamNodes = [NSMutableArray array];
  for (int i = 0, count = [allNodes count]; i < count; ++i) {
    IFTreeNode* node = [allNodes objectAtIndex:i];
    [([node isKindOfClass:[IFTreeNodeParameter class]] ? paramNodes : nonParamNodes) addObject:node];
  }
  int paramsCount = [paramNodes count];

  [paramNodes sortUsingFunction:compareParamNodes context:nil];
  [paramNodes addObjectsFromArray:nonParamNodes];

  NSArray* dag = [self dagFromTopologicallySortedNodes:paramNodes];
  NSMutableArray* types = [NSMutableArray arrayWithCapacity:[paramNodes count]];
  for (int i = 0, count = [paramNodes count]; i < count; ++i)
    [types addObject:[[paramNodes objectAtIndex:i] potentialTypes]];
  NSArray* inferredTypes = nil;
  camlInferTypesForTree(paramsCount, dag, types, &inferredTypes);
  return inferredTypes;
}

- (NSArray*)predecessorIndexesOfNode:(IFTreeNode*)node inArray:(NSArray*)array;
{
  NSArray* parents = [node parents];
  int count = [parents count];
  NSMutableArray* predecessors = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; ++i)
    [predecessors addObject:[NSNumber numberWithInt:[array indexOfObject:[[parents objectAtIndex:i] original]]]];
  return predecessors;
}

- (NSArray*)dagFromTopologicallySortedNodes:(NSArray*)sortedNodes;
{
  int nodesCount = [sortedNodes count];
  NSMutableArray* dag = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i)
    [dag addObject:[self predecessorIndexesOfNode:[sortedNodes objectAtIndex:i] inArray:sortedNodes]];
  return dag;
}

- (BOOL)checkDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
{
  return Bool_val(camlTypecheck(dag, potentialTypes));
}

- (NSArray*)configureDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
{
  NSArray* configuration;
  camlConfigureDAG(dag,potentialTypes,&configuration);
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

static void camlInferTypesForTree(int paramsCount, NSArray* dag, NSArray* types, NSArray** inferredTypes) {
  CAMLparam0();
  CAMLlocal3(camlDAG, camlTypes, camlInferredTypes);
  
  camlDAG = dagToCaml(dag);
  camlTypes = potentialTypesToCaml(types);
  static value* inferClosure = NULL;
  if (inferClosure == NULL)
    inferClosure = caml_named_value("Typechecker.infer");
  camlInferredTypes = caml_callback3(*inferClosure, Val_int(paramsCount), camlDAG, camlTypes);
  
  NSMutableArray* iTypes = [NSMutableArray array];
  while (camlInferredTypes != Val_int(0)) {
    [iTypes addObject:[IFType typeWithCamlType:Field(camlInferredTypes,0)]];
    camlInferredTypes = Field(camlInferredTypes,1);
  }
  *inferredTypes = iTypes;
  CAMLreturn0;
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
  CAMLlocal4(camlDAG, camlTypes, camlConfigurationOption, camlConfiguration);
  
  camlDAG = dagToCaml(dag);
  camlTypes = potentialTypesToCaml(potentialTypes);
  static value* configClosure = NULL;
  if (configClosure == NULL)
    configClosure = caml_named_value("Typechecker.first_valid_configuration");
  camlConfigurationOption = caml_callback2(*configClosure, camlDAG, camlTypes);

  if (!Is_long(camlConfigurationOption)) {
    camlConfiguration = Field(camlConfigurationOption, 0);
    NSMutableArray* config = [NSMutableArray array];
    while (camlConfiguration != Val_int(0)) {
      [config addObject:[NSNumber numberWithInt:Int_val(Field(camlConfiguration,0))]];
      camlConfiguration = Field(camlConfiguration,1);
    }
    *configuration = config;
  } else
    *configuration = nil;
  CAMLreturn0;
}
