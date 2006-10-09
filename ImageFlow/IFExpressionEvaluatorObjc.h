//
//  IFExpressionEvaluatorObjc.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionEvaluator.h"
#import "IFConstantExpression.h"
#import "IFExpressionOptimiser.h"
#import "IFExpressionVisitor.h"
#import "IFCacheingPolicyLRU.h"

@interface IFExpressionEvaluatorObjc : IFExpressionEvaluator {
  NSMutableDictionary* dispatchTable;
  IFExpressionOptimiser* optimiser;
  
  NSMutableArray* recentExpressions;
  IFEnvironment* globalEnvironment;
  IFCacheingPolicyLRU* globalEnvironmentPolicy;
  NSMutableDictionary* globalCache;

  // Visitor state
  IFConstantExpression* result;
}

// protected
- (void)registerSelector:(SEL)selector forOperatorNamed:(NSString*)operatorName;

@end
