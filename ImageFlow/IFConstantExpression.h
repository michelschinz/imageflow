//
//  IFConstantExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"
#import "IFImage.h"

@interface IFConstantExpression : IFExpression {
  int tag;
  id object;
}

+ (IFConstantExpression*)expressionWithArray:(NSArray*)theArray;
+ (IFConstantExpression*)expressionWithTupleElements:(NSArray*)theElements;
+ (IFConstantExpression*)expressionWithPointNS:(NSPoint)thePoint;
+ (IFConstantExpression*)expressionWithWrappedPointNS:(NSValue*)thePoint;
+ (IFConstantExpression*)expressionWithRectNS:(NSRect)theRect;
+ (IFConstantExpression*)expressionWithWrappedRectNS:(NSValue*)thePoint;
+ (IFConstantExpression*)expressionWithRectCG:(CGRect)theRect;
+ (IFConstantExpression*)expressionWithColorNS:(NSColor*)theColor;
+ (IFConstantExpression*)expressionWithString:(NSString*)theString;
+ (IFConstantExpression*)expressionWithInt:(int)theInt;
+ (IFConstantExpression*)expressionWithWrappedInt:(NSNumber*)theInt;
+ (IFConstantExpression*)expressionWithFloat:(float)theFloat;
+ (IFConstantExpression*)expressionWithWrappedFloat:(NSNumber*)theFloat;
+ (IFConstantExpression*)exportActionWithFileURL:(NSURL*)theFileURL image:(CIImage*)theImage exportArea:(CGRect)theExportArea;

+ (IFConstantExpression*)imageConstantExpressionWithIFImage:(IFImage*)theImage;
+ (IFConstantExpression*)errorConstantExpressionWithMessage:(NSString*)theMessage;

@property(readonly) BOOL isArray;
@property(readonly) BOOL isImage;
@property(readonly) BOOL isAction;
@property(readonly) BOOL isError;

@property(readonly) id object;

@property(readonly) IFImage* imageValue;
@property(readonly) NSArray* arrayValue;
@property(readonly) NSArray* flatArrayValue;
@property(readonly) NSArray* tupleValue;
@property(readonly) NSPoint pointValueNS;
@property(readonly) NSRect rectValueNS;
@property(readonly) CGRect rectValueCG;
@property(readonly) NSColor* colorValueNS;
@property(readonly) CIColor* colorValueCI;
@property(readonly) NSString* stringValue;
@property(readonly) int intValue;
@property(readonly) BOOL boolValue;
@property(readonly) float floatValue;

@end
