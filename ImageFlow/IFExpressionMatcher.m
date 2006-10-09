//
//  IFExpressionMatcher.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpressionMatcher.h"


@implementation IFExpressionMatcher

+ (NSDictionary*)matchPattern:(IFExpression*)thePattern withExpression:(IFExpression*)theExpression;
{
  IFExpressionMatcher* matcher = [self new];
  NSDictionary* result = [matcher matchPattern:thePattern withExpression:theExpression];
  [matcher release];
  return result;
}

- (NSDictionary*)matchPattern:(IFExpression*)thePattern withExpression:(IFExpression*)theExpression;
{
  NSAssert(result == nil, @"non-nil result before starting");
  IFExpression* bkpExpression = expression;
  expression = theExpression;
  [thePattern accept:self];
  expression = bkpExpression;
  NSDictionary* theResult = result;
  result = nil;
  return theResult;
}

- (void)caseOperatorExpression:(IFOperatorExpression*)pattern;
{
  if (![expression isKindOfClass:[IFOperatorExpression class]])
    return;
  IFOperatorExpression* opExpression = (IFOperatorExpression*)expression;
  if ([pattern operator] != [opExpression operator])
    return;
  NSArray* patternOperands = [pattern operands];
  NSArray* expressionOperands = [opExpression operands];
  NSAssert([patternOperands count] == [expressionOperands count], @"incompatible number of operands");

  NSMutableDictionary* compositeEnv = [NSMutableDictionary dictionary];
  for (int i = 0; i < [patternOperands count]; ++i) {
    NSDictionary* d = [self matchPattern:[patternOperands objectAtIndex:i] withExpression:[expressionOperands objectAtIndex:i]];
    if (d == nil)
      return;
    [compositeEnv addEntriesFromDictionary:d];
  }
  result = compositeEnv;
}

- (void)caseParentExpression:(IFParentExpression*)pattern;
{
  result = [expression isEqual:pattern] ? [NSDictionary dictionary] : nil;    
}

- (void)caseVariableExpression:(IFVariableExpression*)pattern;
{
  result = [expression isEqual:pattern] ? [NSDictionary dictionary] : nil;    
}

- (void)caseConstantExpression:(IFConstantExpression*)pattern;
{
  result = [expression isEqual:pattern] ? [NSDictionary dictionary] : nil;    
}

- (void)caseWildcardExpression:(IFWildcardExpression*)pattern;
{
  result = [NSDictionary dictionaryWithObject:expression forKey:[pattern name]];
}

@end
