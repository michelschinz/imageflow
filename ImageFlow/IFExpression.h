//
//  IFExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <caml/mlvalues.h>

#import "IFEnvironment.h"
#import "IFExpressionTags.h"

@interface IFExpression : NSObject<NSCopying> {
  BOOL camlRepresentationIsValid;
  value camlRepresentation;
}

// MARK: Constructors
+ (id)expressionWithXML:(NSXMLElement*)xmlTree;
+ (id)expressionWithCamlValue:(value)camlValue;

+ (IFExpression*)fail;
+ (IFExpression*)extentOf:(IFExpression*)imageExpr;
+ (IFExpression*)resample:(IFExpression*)imageExpr by:(float)scale;
+ (IFExpression*)translate:(IFExpression*)expression byX:(float)x Y:(float)y;
+ (IFExpression*)crop:(IFExpression*)expression along:(NSRect)rectangle;
+ (IFExpression*)blendBackground:(IFExpression*)background withForeground:(IFExpression*)foreground inMode:(IFExpression*)mode;
+ (IFExpression*)histogramOf:(IFExpression*)imageExpr;
+ (IFExpression*)checkerboardCenteredAt:(NSPoint)center color0:(NSColor*)color0 color1:(NSColor*)color1 width:(float)width sharpness:(float)sharpness;
+ (IFExpression*)maskToImage:(IFExpression*)maskExpression;
+ (IFExpression*)arrayCreate:(NSArray*)arrayElements;
+ (IFExpression*)arrayGet:(IFExpression*)arrayExpression index:(unsigned)index;
+ (IFExpression*)tupleCreate:(NSArray*)tupleElements;
+ (IFExpression*)tupleGet:(IFExpression*)tupleExpression index:(unsigned)index;

+ (IFExpression*)lambdaWithBody:(IFExpression*)body;
+ (IFExpression*)mapWithFunction:(IFExpression*)theFunction array:(IFExpression*)theArray;
+ (IFExpression*)applyWithFunction:(IFExpression*)theFunction argument:(IFExpression*)theArgument;
+ (IFExpression*)primitiveWithTag:(IFPrimitiveTag)theTag operand:(IFExpression*)theOperand;
+ (IFExpression*)primitiveWithTag:(IFPrimitiveTag)theTag operands:(IFExpression*)firstOperand, ...;
+ (IFExpression*)primitiveWithTag:(IFPrimitiveTag)theTag operandsArray:(NSArray*)theOperands;
+ (IFExpression*)argumentWithIndex:(unsigned)theIndex;

// MARK: Properties

@property(readonly) int tag;
@property(readonly) NSUInteger hash;

// MARK: Caml / XML conversion

- (NSXMLElement*)asXML;
- (value)asCaml;

// MARK: -
// MARK: PROTECTED

- (value)camlRepresentation;

@end
