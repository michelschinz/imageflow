//
//  IFExpressionOptimiser.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionVisitor.h"
#import "IFEnvironment.h"

@interface IFExpressionOptimiser : IFExpressionVisitor {
  NSArray* rules;
  NSDictionary* cache;
  
  // Visitor state
  int phase;
  IFExpression* result;
}

+ (id)optimiserWithRules:(NSArray*)theRules;
- (id)initWithRules:(NSArray*)theRules;

- (IFExpression*)optimiseExpression:(IFExpression*)expression withCache:(NSDictionary*)theCache;
- (IFExpression*)optimiseExpression:(IFExpression*)expression;

@end
