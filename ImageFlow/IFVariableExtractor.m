//
//  IFVariableExtractor.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFVariableExtractor.h"


@implementation IFVariableExtractor

+ (id)extractor;
{
  return [[self new] autorelease];
}

- (NSSet*)variablesIn:(IFExpression*)expression;
{
  result = [NSMutableSet set];
  [expression accept:self];
  NSSet* variables = result;
  result = nil;
  return variables;
}

- (void)caseOperatorExpression:(IFOperatorExpression*)expression;
{
  [[[expression operands] do] accept:self];
}

- (void)caseVariableExpression:(IFVariableExpression*)expression;
{
  [result addObject:[expression name]];
}

@end
