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
  NSUInteger hash;
}

+ (id)nop;
+ (id)extentOf:(IFExpression*)imageExpr;
+ (id)resample:(IFExpression*)imageExpr by:(float)scale;
+ (id)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
+ (id)crop:(IFExpression*)expression along:(NSRect)rectangle;
+ (id)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(IFConstantExpression*)mode;
+ (id)histogramOf:(IFExpression*)imageExpr;
+ (id)checkerboardCenteredAt:(NSPoint)center color0:(NSColor*)color0 color1:(NSColor*)color1 width:(float)width sharpness:(float)sharpness;
+ (id)maskToImage:(IFExpression*)maskExpression;
+ (id)arrayGet:(IFExpression*)arrayExpression index:(unsigned)index;

+ (id)expressionWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;
+ (id)expressionWithOperatorNamed:(NSString*)theOperatorName operands:(IFExpression*)firstOperand, ...;
- (id)initWithOperator:(IFOperator*)theOperator operands:(NSArray*)theOperands;

@property(readonly) IFOperator* operator;
@property(readonly) NSArray* operands;
- (IFExpression*)operandAtIndex:(int)index;

@end
