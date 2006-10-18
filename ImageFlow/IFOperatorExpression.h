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
+ (id)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
+ (id)crop:(IFExpression*)expression along:(NSRect)rectangle;
+ (id)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(NSString*)mode;
+ (id)histogramOf:(IFExpression*)imageExpr;

+ (id)expressionWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;
- (id)initWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;

- (IFOperator*)operator;
- (NSArray*)operands;
- (IFExpression*)operandAtIndex:(int)index;

@end
