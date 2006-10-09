//
//  IFExpressionMatcher.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionVisitor.h"

@interface IFExpressionMatcher : IFExpressionVisitor {
  NSDictionary* result;
  IFExpression* expression;
}

+ (NSDictionary*)matchPattern:(IFExpression*)thePattern withExpression:(IFExpression*)theExpression;
- (NSDictionary*)matchPattern:(IFExpression*)thePattern withExpression:(IFExpression*)theExpression;

@end
