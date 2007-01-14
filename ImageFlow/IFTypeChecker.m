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

@implementation IFTypeChecker

+ (IFTypeChecker*)sharedInstance;
{
  static IFTypeChecker* instance = nil;
  if (instance == nil)
    instance = [self new];
  return instance;
}

static value camlCons(value h, value t) {
  CAMLparam2(h,t);
  CAMLlocal1(cell);
  cell = caml_alloc(2, 0);
  Store_field(cell, 0, h);
  Store_field(cell, 1, t);
  CAMLreturn(cell);
}

static value graphToCaml(NSArray* graph) {
  CAMLparam0();
  CAMLlocal2(camlGraph, camlPreds);

  camlGraph = Val_int(0);
  for (int i = [graph count] - 1; i >= 0; --i) {
    NSArray* preds = [graph objectAtIndex:i];
    camlPreds = Val_int(0);
    for (int j = [preds count] - 1; j >= 0; --j) {
      int c = [[preds objectAtIndex:j] intValue];
      camlPreds = camlCons(Val_int(c), camlPreds);
    }
    camlGraph = camlCons(camlPreds, camlGraph);
  }
  CAMLreturn(camlGraph);
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

static void camlInferTypesForTree(int paramsCount, NSArray* graph, NSArray* types, NSArray** inferredTypes) {
  CAMLparam0();
  CAMLlocal3(camlGraph, camlTypes, camlInferredTypes);
  
  camlGraph = graphToCaml(graph);
  camlTypes = potentialTypesToCaml(types);
  static value* inferClosure = NULL;
  if (inferClosure == NULL)
    inferClosure = caml_named_value("Typechecker.infer");
  camlInferredTypes = caml_callback3(*inferClosure, Val_int(paramsCount), camlGraph, camlTypes);
  
  NSMutableArray* iTypes = [NSMutableArray array];
  while (camlInferredTypes != Val_int(0)) {
    [iTypes addObject:[IFType typeWithCamlType:Field(camlInferredTypes,0)]];
    camlInferredTypes = Field(camlInferredTypes,1);
  }
  *inferredTypes = iTypes;
  CAMLreturn0;
}

- (NSArray*)graphFromTopologicallySortedNodes:(NSArray*)sortedNodes;
{
  int nodesCount = [sortedNodes count];
  NSMutableArray* graph = [NSMutableArray arrayWithCapacity:nodesCount];
  for (int i = 0; i < nodesCount; ++i) {
    IFTreeNode* node = [sortedNodes objectAtIndex:i];
    NSArray* parents = [node parents];
    NSMutableArray* predecessors = [NSMutableArray arrayWithCapacity:[parents count]];
    for (int j = 0, pCount = [parents count]; j < pCount; ++j)
      [predecessors addObject:[NSNumber numberWithInt:[sortedNodes indexOfObject:[[parents objectAtIndex:j] original]]]];
    [graph addObject:predecessors];
  }
  return graph;
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

  NSArray* graph = [self graphFromTopologicallySortedNodes:paramNodes];
  NSMutableArray* types = [NSMutableArray arrayWithCapacity:[paramNodes count]];
  for (int i = 0, count = [paramNodes count]; i < count; ++i)
    [types addObject:[[paramNodes objectAtIndex:i] potentialTypes]];
  NSArray* inferredTypes = nil;
  camlInferTypesForTree(paramsCount, graph, types, &inferredTypes);
  return inferredTypes;
}

@end
