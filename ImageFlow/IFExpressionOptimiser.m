//
//  IFExpressionOptimiser.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpressionOptimiser.h"
#import "IFRewriteRule.h"

@implementation IFExpressionOptimiser

+ (id)optimiserWithRules:(NSArray*)theRules;
{
  return [[[self alloc] initWithRules:theRules] autorelease];
}

- (id)initWithRules:(NSArray*)theRules;
{
  if (![super init])
    return nil;
  rules = [theRules retain];
  result = nil;
  return self;
}

- (void)dealloc;
{
  [rules release];
  rules = nil;
  [super dealloc];
}

- (IFExpression*)optimiseExpression:(IFExpression*)expression withCache:(NSDictionary*)theCache;
{
  cache = theCache;
  IFExpression* optimisedExpression = [self optimiseExpression:expression];
  cache = nil;
  return optimisedExpression;
}

- (IFExpression*)optimiseExpression:(IFExpression*)expression;
{
  IFExpression* prevExpression;
  IFExpression* optimisedExpression = expression;
  int roundsLeft = 20;
  do {
    prevExpression = optimisedExpression;
    for (phase = 0; phase <= 1; ++phase) {
      result = nil;
      [optimisedExpression accept:self];
      optimisedExpression = (result != nil) ? result : prevExpression;
    }
  } while (![prevExpression isEqual:optimisedExpression] && --roundsLeft > 0);
  
  if (roundsLeft == 0)
    NSLog(@"potential infinite loop when optimising expression %@ (last two results: %@ and %@)",
          expression, prevExpression, optimisedExpression);

  return optimisedExpression;
}

- (void)caseOperatorExpression:(IFOperatorExpression*)expression;
{
  switch (phase) {
    case 0: {
      // Rule-based rewriting.
      NSArray* operands = [expression operands];
      NSMutableArray* optimisedOperands = [NSMutableArray arrayWithCapacity:[operands count]];
      for (int i = 0, count = [operands count]; i < count; ++i) {
        result = nil;
        [[operands objectAtIndex:i] accept:self];
        [optimisedOperands addObject:(result != nil ? result : [operands objectAtIndex:i])];
      }
      result = [IFOperatorExpression expressionWithOperator:[expression operator] operands:optimisedOperands];
      for (int i = 0, count = [rules count]; i < count; ++i)
        result = [[rules objectAtIndex:i] rewriteExpression:result];
    } break;
  
    case 1: {
      // Cache-based rewriting
      NSString* varName = [cache objectForKey:expression];
      result = (varName != nil) ? [IFVariableExpression expressionWithName:varName] : expression;
    } break;
      
    default:
      NSAssert(NO, @"invalid phase number");
  }
}

@end
