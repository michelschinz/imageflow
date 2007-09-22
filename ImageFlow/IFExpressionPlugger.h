//
//  IFExpressionPlugger.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"
#import "IFExpressionVisitor.h"

@interface IFExpressionPlugger : IFExpressionVisitor {
  IFExpression* result;
  NSDictionary* environment;
  int mode;
}

+ (IFExpression*)plugValuesInExpression:(IFExpression*)expression withValuesFromVariablesEnvironment:(NSDictionary*)environment;
+ (IFExpression*)plugValuesInExpression:(IFExpression*)expression withValuesFromParentsEnvironment:(NSDictionary*)environment;

@end
