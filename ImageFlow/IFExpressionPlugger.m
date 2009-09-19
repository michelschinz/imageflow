//
//  IFExpressionPlugger.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpressionPlugger.h"

typedef enum {
  IFExpressionPluggerModeVariables,
  IFExpressionPluggerModeParents,
} IFExpressionPluggerMode;

@interface IFExpressionPlugger ()
+ (IFExpression*)plugValuesInExpression:(IFExpression*)expression withValuesFromEnvironment:(NSDictionary*)environment mode:(IFExpressionPluggerMode)mode;
- (id)initWithEnvironment:(NSDictionary*)theEnvironment mode:(IFExpressionPluggerMode)theMode;
- (void)substituteUsingKey:(NSObject*)key ifInMode:(IFExpressionPluggerMode)expectedMode defaultExpression:(IFExpression*)expression;
@end

@implementation IFExpressionPlugger

+ (IFExpression*)plugValuesInExpression:(IFExpression*)expression withValuesFromVariablesEnvironment:(NSDictionary*)environment;
{
  return [self plugValuesInExpression:expression withValuesFromEnvironment:environment mode:IFExpressionPluggerModeVariables];
}

+ (IFExpression*)plugValuesInExpression:(IFExpression*)expression withValuesFromParentsEnvironment:(NSDictionary*)environment;
{
  return [self plugValuesInExpression:expression withValuesFromEnvironment:environment mode:IFExpressionPluggerModeParents];
}

- (IFExpression*)plugValuesInExpression:(IFExpression*)expression;
{
  NSAssert(result == nil, @"non-nil result before starting");
  [expression accept:self];
  IFExpression* theResult = result;
  result = nil;
  return theResult;
}

- (void)caseLambdaExpression:(IFLambdaExpression*)expression;
{
  result = [IFLambdaExpression lambdaExpressionWithBody:[self plugValuesInExpression:expression.body]];
}

- (void)caseOperatorExpression:(IFOperatorExpression*)expression;
{
  NSMutableArray* pluggedOperands = [NSMutableArray array];
  for (IFExpression* operand in expression.operands)
    [pluggedOperands addObject:[self plugValuesInExpression:operand]];
  result = [IFOperatorExpression expressionWithOperator:expression.operator operands:pluggedOperands];
}

- (void)caseParentExpression:(IFParentExpression*)expression;
{
  [self substituteUsingKey:[NSNumber numberWithInt:[expression index]] ifInMode:IFExpressionPluggerModeParents defaultExpression:expression];
}

- (void)caseVariableExpression:(IFVariableExpression*)expression;
{
  [self substituteUsingKey:[expression name] ifInMode:IFExpressionPluggerModeVariables defaultExpression:expression];
  if (result != nil && ![result isKindOfClass:[IFExpression class]])
    result = [IFConstantExpression expressionWithObject:result];
}

- (void)caseArgumentExpression:(IFArgumentExpression*)expression;
{
  result = expression;
}

- (void)caseConstantExpression:(IFConstantExpression*)expression;
{
  result = expression;
}

// MARK: -
// MARK: PRIVATE

+ (IFExpression*)plugValuesInExpression:(IFExpression*)expression withValuesFromEnvironment:(NSDictionary*)environment mode:(IFExpressionPluggerMode)mode;
{
  IFExpressionPlugger* plugger = [[self alloc] initWithEnvironment:environment mode:mode];
  IFExpression* result = [plugger plugValuesInExpression:expression];
  [plugger release];
  return result;
}

- (id)initWithEnvironment:(NSDictionary*)theEnvironment mode:(IFExpressionPluggerMode)theMode;
{
  if (![super init])
    return nil;
  environment = [theEnvironment retain];
  mode = theMode;
  return self;
}

- (void)dealloc {
  OBJC_RELEASE(environment);
  [super dealloc];
}

- (void)substituteUsingKey:(NSObject*)key ifInMode:(IFExpressionPluggerMode)expectedMode defaultExpression:(IFExpression*)expression;
{
  if (mode == expectedMode) {
    result = [environment objectForKey:key];
    if (result == nil)
      result = expression;
  } else
    result = expression;
}  

@end
