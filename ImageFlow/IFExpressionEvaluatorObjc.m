//
//  IFExpressionEvaluatorObjc.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpressionEvaluatorObjc.h"
#import "IFRewriteRule.h"
#import "IFImageConstantExpression.h"
#import "IFVariableExtractor.h"
#import "IFUtilities.h"

#define RECENT_EXPRESSIONS_COUNT 20

@interface IFExpressionEvaluatorObjc (Private)
- (void)makeVariableForExpression:(IFExpression*)expression value:(IFConstantExpression*)evaluatedExpression;
- (void)registerRecentExpression:(IFExpression*)expression;
- (BOOL)isRecurrentExpression:(IFExpression*)expression;
@end

@implementation IFExpressionEvaluatorObjc

- (id)init;
{
  if (![super init])
    return nil;
  dispatchTable = [NSMutableDictionary new];
  optimiser = [[IFExpressionOptimiser optimiserWithRules:[IFRewriteRule allRules]] retain];
  
  recentExpressions = [[NSMutableArray alloc] initWithCapacity:(RECENT_EXPRESSIONS_COUNT + 1)];
  globalEnvironment = [IFEnvironment new];
  globalEnvironmentPolicy = [[IFCacheingPolicyLRU alloc] initWithCapacity:20 slack:5];
  globalCache = [NSMutableDictionary new];

  [self registerSelector:@selector(evaluateNop:) forOperatorNamed:@"nop"];
  // arithmetic operations
  [self registerSelector:@selector(evaluateMul:) forOperatorNamed:@"mul"];
  [self registerSelector:@selector(evaluatePointMul:) forOperatorNamed:@"point-mul"];
  //   rectangles
  [self registerSelector:@selector(evaluateRectMul:) forOperatorNamed:@"rect-mul"];
  [self registerSelector:@selector(evaluateRectUnion:) forOperatorNamed:@"rect-union"];
  [self registerSelector:@selector(evaluateRectOutset:) forOperatorNamed:@"rect-outset"];
  [self registerSelector:@selector(evaluateRectTranslate:) forOperatorNamed:@"rect-translate"];
  
  return self;
}

- (void) dealloc {
  [globalCache release];
  globalCache = nil;
  [globalEnvironmentPolicy release];
  globalEnvironmentPolicy = nil;
  [globalEnvironment release];
  globalEnvironment = nil;
  [recentExpressions release];
  recentExpressions = nil;
  [optimiser release];
  optimiser = nil;
  [dispatchTable release];
  dispatchTable = nil;
  [super dealloc];
}

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
{
  IFExpression* expressionToEvaluate = [optimiser optimiseExpression:expression withCache:globalCache];

  result = nil;
  [expressionToEvaluate accept:self];
  NSAssert(result != nil, @"nil evaluation result");
  IFConstantExpression* evaluatedExpression = result;
  
  // TODO use isCostly (which has to be written first)
  if ([expressionToEvaluate isKindOfClass:[IFOperatorExpression class]]
      && [evaluatedExpression isKindOfClass:[IFImageConstantExpression class]]) {
    [self registerRecentExpression:expressionToEvaluate];
    if ([self isRecurrentExpression:expressionToEvaluate])
      [self makeVariableForExpression:expressionToEvaluate value:evaluatedExpression];
  }

  return evaluatedExpression;
}

- (void)clearCache;
{
  [globalCache removeAllObjects]; // TODO what about the environment?
}

- (void)registerSelector:(SEL)selector forOperatorNamed:(NSString*)operatorName;
{
  [dispatchTable setObject:[NSValue valueWithPointer:selector] forKey:[IFOperator operatorForName:operatorName]];
}

#pragma mark Visitor methods

- (void)caseOperatorExpression:(IFOperatorExpression*)expression;
{
  NSArray* operands = [expression operands];
  NSMutableArray* evaluatedOperands = [NSMutableArray new];
  for (int i = 0; i < [operands count]; ++i) {
    IFConstantExpression* evaluatedOperand = [self evaluateExpression:[operands objectAtIndex:i]];
    if (evaluatedOperand == [IFExpressionEvaluator invalidValue]) {
      result = [IFExpressionEvaluator invalidValue];
      return;
    }
    [evaluatedOperands addObject:evaluatedOperand];
  }
  
  IFOperator* operator = [expression operator];
  SEL evaluationMethodSelector = [(NSValue*)[dispatchTable objectForKey:operator] pointerValue];
  NSAssert1(evaluationMethodSelector != nil, @"no evaluator for operator %@",operator);
  result = [self performSelector:evaluationMethodSelector withObject:evaluatedOperands];
}

- (void)caseParentExpression:(IFParentExpression*)expression;
{
  result = [IFExpressionEvaluator invalidValue];
}

- (void)caseVariableExpression:(IFVariableExpression*)expression;
{
  NSString* varName = [expression name];
  [globalEnvironmentPolicy registerAccess:varName];
  result = [globalEnvironment valueForKey:varName];
}

- (void)caseWildcardExpression:(IFWildcardExpression*)expression;
{
  NSAssert1(NO, @"cannot evaluate expression: %@",expression);
}

- (void)caseConstantExpression:(IFConstantExpression*)expression;
{
  result = expression;
}

@end

@implementation IFExpressionEvaluatorObjc (Private)

// Debugging (used by the cache viewer)
- (NSArray*)cachedExpressions;
{
  return [globalCache allKeys];
}

- (void)makeVariableForExpression:(IFExpression*)expression value:(IFConstantExpression*)evaluatedExpression;
{
  [self willChangeValueForKey:@"cachedExpressions"]; // for cache viewer, see above

  static int varCounter = 0;
  NSString* varName = [NSString stringWithFormat:@"var$%d",++varCounter];
  [globalCache setObject:varName forKey:expression];
  [globalEnvironment setValue:evaluatedExpression forKey:varName];
  [globalEnvironmentPolicy registerAccess:varName];
  
  NSSet* varsToRemove = [globalEnvironmentPolicy keysToRemove];
  if ([varsToRemove count] > 0) {
    IFVariableExtractor* varExtractor = [IFVariableExtractor extractor];
    // Remove variables from enviroment...
    [[globalEnvironment do] removeValueForKey:[varsToRemove each]];
    // ...and from cache.
    NSMutableArray* cacheKeysToRemove = [NSMutableArray array];
    NSEnumerator* cacheKeysEnum = [globalCache keyEnumerator];
    IFExpression* key;
    while (key = [cacheKeysEnum nextObject]) {
      NSMutableSet* variables = [NSMutableSet setWithObject:[globalCache objectForKey:key]];
      [variables unionSet:[varExtractor variablesIn:key]];
      if ([variables intersectsSet:varsToRemove])
        [cacheKeysToRemove addObject:key];
    }
    [globalCache removeObjectsForKeys:cacheKeysToRemove];
    [globalEnvironmentPolicy clearKeysToRemove];
  }
  
  [self didChangeValueForKey:@"cachedExpressions"]; // for cache viewer, see above
}

- (void)registerRecentExpression:(IFExpression*)expression;
{
  NSNumber* exprHash = [NSNumber numberWithUnsignedInt:[expression hash]];
  [recentExpressions removeObject:exprHash];
  [recentExpressions insertObject:exprHash atIndex:0];
  
  if ([recentExpressions count] > RECENT_EXPRESSIONS_COUNT)
    [recentExpressions removeLastObject];
  
  NSAssert([recentExpressions count] <= RECENT_EXPRESSIONS_COUNT, @"unexpected number of recent expressions");
}

- (BOOL)isRecurrentExpression:(IFExpression*)expression;
{
  return [recentExpressions indexOfObject:[NSNumber numberWithUnsignedInt:[expression hash]]] != NSNotFound;
}

- (IFConstantExpression*)evaluateNop:(NSArray*)operands;
{
  // Image nop(args: *)
  return [IFExpressionEvaluator invalidValue];
}

- (IFConstantExpression*)evaluateMul:(NSArray*)operands;
{
  // Float mul(x: Float, y: Float)
  return [IFConstantExpression expressionWithFloat:[[operands objectAtIndex:0] floatValue] * [[operands objectAtIndex:1] floatValue]];
}

- (IFConstantExpression*)evaluatePointMul:(NSArray*)operands;
{
  // Point point-mul(p: Point, s: Float)
  NSPoint p = [[operands objectAtIndex:0] pointValueNS];
  float s = [[operands objectAtIndex:1] floatValue];
  return [IFConstantExpression expressionWithPointNS:NSMakePoint(p.x * s, p.y * s)];
}

- (IFConstantExpression*)evaluateRectMul:(NSArray*)operands;
{
  // Rect rect-mul(r: Rect, s: Float)
  NSRect r = [[operands objectAtIndex:0] rectValueNS];
  float s = [[operands objectAtIndex:1] floatValue];
  return [IFConstantExpression expressionWithRectNS:NSMakeRect(NSMinX(r) * s, NSMinY(r) * s, NSWidth(r) * s, NSHeight(r) * s)];
}

- (IFConstantExpression*)evaluateRectUnion:(NSArray*)operands;
{
  // Rect rect-union(r1: Rect, r2: Rect)
  NSRect r1 = [[operands objectAtIndex:0] rectValueNS];
  NSRect r2 = [[operands objectAtIndex:1] rectValueNS];
  return [IFConstantExpression expressionWithRectNS:NSUnionRect(r1,r2)];
}

- (IFConstantExpression*)evaluateRectOutset:(NSArray*)operands;
{
  // Rect rect-outset(r: Rect, o: Float)
  NSRect r = [[operands objectAtIndex:0] rectValueNS];
  float o = [[operands objectAtIndex:1] floatValue];
  return [IFConstantExpression expressionWithRectNS:NSInsetRect(r,-o,-o)];
}

- (IFConstantExpression*)evaluateRectTranslate:(NSArray*)operands;
{
  // Rect rect-translate(r: Rect, p: Point)
  NSRect r = [[operands objectAtIndex:0] rectValueNS];
  NSPoint p = [[operands objectAtIndex:1] pointValueNS];
  return [IFConstantExpression expressionWithRectNS:NSOffsetRect(r,p.x,p.y)];
}

@end
