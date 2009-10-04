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

- (NSArray*)arrayValue;
- (NSArray*)flatArrayValue;
- (NSArray*)tupleValue;
- (NSObject*)objectValue;
- (NSPoint)pointValueNS;
- (NSRect)rectValueNS;
- (CGRect)rectValueCG;
- (NSColor*)colorValueNS;
- (CIColor*)colorValueCI;
- (NSString*)stringValue;
- (int)intValue;
- (BOOL)boolValue;
- (float)floatValue;

- (BOOL)isArray;
- (BOOL)isImage;
- (BOOL)isError;

+ (id)expressionWithCamlValue:(value)camlValue;

// MARK: -
// MARK: PROTECTED

- initWithObject:(NSObject*)theConstant tag:(int)theTag;

@end
