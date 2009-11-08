//
//  IFConstantExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFConstantExpression : IFExpression {
  NSObject* object;
  int tag;
}

+ expressionWithObject:(NSObject*)theConstant tag:(int)theTag;

+ expressionWithArray:(NSArray*)theArray;
+ expressionWithTupleElements:(NSArray*)theElements;
+ expressionWithPointNS:(NSPoint)thePoint;
+ expressionWithRectNS:(NSRect)theRect;
+ expressionWithRectCG:(CGRect)theRect;
+ expressionWithColorNS:(NSColor*)theColor;
+ expressionWithString:(NSString*)theString;
+ expressionWithInt:(int)theInt;
+ expressionWithFloat:(float)theFloat;

@property(readonly) int tag;

@property(readonly) NSArray* arrayValue;
@property(readonly) NSArray* flatArrayValue;
@property(readonly) NSArray* tupleValue;
@property(readonly) NSObject* objectValue;
@property(readonly) NSPoint pointValueNS;
@property(readonly) NSRect rectValueNS;
@property(readonly) CGRect rectValueCG;
@property(readonly) NSColor* colorValueNS;
@property(readonly) CIColor* colorValueCI;
@property(readonly) NSString* stringValue;
@property(readonly) int intValue;
@property(readonly) BOOL boolValue;
@property(readonly) float floatValue;

@property(readonly) BOOL isArray;
@property(readonly) BOOL isImage;
@property(readonly) BOOL isAction;
@property(readonly) BOOL isError;

+ (id)expressionWithCamlValue:(value)camlValue;

// MARK: -
// MARK: PROTECTED

- initWithObject:(NSObject*)theConstant tag:(int)theTag;

@end
