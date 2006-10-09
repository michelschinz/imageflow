//
//  IFOperatorExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFOperatorExpression : IFExpression {
  IFOperator* operator;
  NSArray* operands;
  unsigned hash;
}

+ (id)nop;
+ (id)extentOf:(IFExpression*)imageExpr;
+ (id)resample:(IFExpression*)imageExpr by:(float)scale;
+ (id)histogramOf:(IFExpression*)imageExpr;
+ (id)brush:(NSString*)style color:(NSColor*)color size:(float)size;
+ (id)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
+ (id)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(NSString*)mode;

+ (id)expressionWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;
- (id)initWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;

- (IFOperator*)operator;
- (NSArray*)operands;
- (IFExpression*)operandAtIndex:(int)index;

@end
