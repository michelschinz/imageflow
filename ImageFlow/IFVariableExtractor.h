//
//  IFVariableExtractor.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionVisitor.h"

@interface IFVariableExtractor : IFExpressionVisitor {
  NSMutableSet* result;
}

+ (id)extractor;

- (NSSet*)variablesIn:(IFExpression*)expression;

@end
