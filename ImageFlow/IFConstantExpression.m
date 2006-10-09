//
//  IFConstantExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFConstantExpression.h"
#import "IFXMLCoder.h"
#import "IFUtilities.h"
#import "IFImageConstantExpression.h"
#import "IFExpressionVisitor.h"
#import "IFExpressionTags.h"
#import "IFExpressionEvaluator.h"

#import <caml/alloc.h>
#import <caml/memory.h>
#import <caml/callback.h>

#import "ocaml/bridge/objc.h"

@implementation IFConstantExpression

+ expressionWithArray:(NSArray*)theArray;
{
  return [self expressionWithObject:theArray];
}

+ expressionWithObject:(NSObject*)theObject;
{
  return [[[self alloc] initWithObject:theObject] autorelease];
}

+ expressionWithPointNS:(NSPoint)thePoint;
{
  return [self expressionWithObject:[NSValue valueWithPoint:thePoint]];
}

+ expressionWithRectNS:(NSRect)theRect;
{
  return [self expressionWithObject:[NSValue valueWithRect:theRect]];
}

+ expressionWithRectCG:(CGRect)theRect;
{
  return [self expressionWithRectNS:NSRectFromCGRect(theRect)];
}

+ expressionWithColorNS:(NSColor*)theColor;
{
  return [self expressionWithObject:theColor];
}

+ expressionWithString:(NSString*)theString;
{
  return [self expressionWithObject:theString];
}

+ expressionWithInt:(int)theInt;
{
  return [self expressionWithObject:[NSNumber numberWithInt:theInt]];
}

+ expressionWithFloat:(float)theFloat;
{
  return [self expressionWithObject:[NSNumber numberWithFloat:theFloat]];
}

- initWithObject:(NSObject*)theObject;
{
  if (![super init])
    return nil;
  object = [theObject retain];
  return self;
}

- (void) dealloc {
  [object release];
  object = nil;
  [super dealloc];
}

- (NSString*)description;
{
  return [object description];
}

- (NSObject*)objectValue;
{
  return object;
}

- (NSArray*)arrayValue;
{
  NSAssert1([object isKindOfClass:[NSArray class]], @"object is not a value: %@",object);
  return (NSArray*)object;
}

- (NSPoint)pointValueNS;
{
  NSAssert1([object isKindOfClass:[NSValue class]], @"object is not a value: %@",object);
  NSValue* value = (NSValue*)object;
  NSAssert1(strcmp([value objCType],@encode(NSPoint)) == 0, @"object is not a point: %@",object);
  return [value pointValue];
}

- (NSRect)rectValueNS;
{
  NSAssert1([object isKindOfClass:[NSValue class]], @"object is not a value: %@",object);
  NSValue* value = (NSValue*)object;
  NSAssert1(strcmp([value objCType],@encode(NSRect)) == 0, @"object is not a rectangle: %@",object);
  return [value rectValue];
}

- (CGRect)rectValueCG;
{
  return CGRectFromNSRect([self rectValueNS]);
}

- (NSColor*)colorValueNS;
{
  NSAssert1([object isKindOfClass:[NSColor class]], @"object is not a color (NS): %@",object);
  return (NSColor*)object;
}

- (CIColor*)colorValueCI;
{
  NSAssert1([object isKindOfClass:[NSColor class]], @"object is not a color (NS): %@",object);
  return [[[CIColor alloc] initWithColor:(NSColor*)object] autorelease];
}

- (NSString*)stringValue;
{
  NSAssert1([object isKindOfClass:[NSString class]], @"object is not a string: %@",object);
  return (NSString*)object;
}

- (BOOL)boolValue;
{
  NSAssert1([object isKindOfClass:[NSNumber class]], @"object is not a number: %@",object);
  return [(NSNumber*)object boolValue] ? YES : NO;
}

- (int)intValue;
{
  NSAssert1([object isKindOfClass:[NSNumber class]], @"object is not a number: %@",object);
  return [(NSNumber*)object intValue];
}

- (float)floatValue;
{
  NSAssert1([object isKindOfClass:[NSNumber class]], @"object is not a number: %@",object);
  return [(NSNumber*)object floatValue];
}

- (void)accept:(IFExpressionVisitor*)visitor;
{
  [visitor caseConstantExpression:self];
}

- (unsigned)hash;
{
  return [object hash];
}

- (BOOL)isEqualAtRoot:(id)other;
{
  return [other isKindOfClass:[IFConstantExpression class]] && [object isEqual:[other objectValue]];
}

#pragma mark XML input/output

- (id)initWithXML:(NSXMLElement*)xml;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  return [self initWithObject:[xmlCoder decodeString:[xml stringValue] typeName:[[xml attributeForName:@"type"] stringValue]]];
}

- (NSXMLElement*)asXML;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  NSXMLElement* elem = [NSXMLElement elementWithName:@"constant"];
  [elem addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:[xmlCoder typeNameForData:object]]];
  [elem setStringValue:[xmlCoder encodeData:object]];
  return elem;
}

#pragma mark Caml representation

static void expressionWithCamlValue(value camlValue, IFConstantExpression** result) {
  CAMLparam1(camlValue);
  CAMLlocal1(contents);
  IFExpressionTag tag = Tag_val(camlValue);
  switch (tag) {
    case IFExpressionTag_Image: {
      static value* imageToIFImageClosure = NULL;
      if (imageToIFImageClosure == NULL)
        imageToIFImageClosure = caml_named_value("Image.to_ifimage");
      contents = caml_callback(*imageToIFImageClosure,Field(camlValue,0));
      *result = [IFImageConstantExpression imageConstantExpressionWithIFImage:objc_unwrap(contents)];
    } break;
    
    case IFExpressionTag_Color: {
      NSLog(@"TODO color");
    } break;
      
    case IFExpressionTag_Rect: {
      static value* rectCAClosure = NULL;
      if (rectCAClosure == NULL)
        rectCAClosure = caml_named_value("Rect.components_array");
      contents = caml_callback(*rectCAClosure,Field(camlValue, 0));
      NSRect r = NSMakeRect(Double_field(contents,0),Double_field(contents, 1),Double_field(contents, 2),Double_field(contents, 3));
      *result = [IFConstantExpression expressionWithRectNS:r];
    } break;
      
    case IFExpressionTag_Point: {
      static value* pointCAClosure = NULL;
      if (pointCAClosure == NULL)
        pointCAClosure = caml_named_value("Point.components_array");
      contents = caml_callback(*pointCAClosure,Field(camlValue, 0));
      NSPoint p = NSMakePoint(Double_field(contents,0),Double_field(contents, 1));
      *result = [IFConstantExpression expressionWithPointNS:p];
    } break;
      
    case IFExpressionTag_String:
      *result = [IFConstantExpression expressionWithString:[NSString stringWithCString:String_val(Field(camlValue, 0))
                                                                              encoding:NSISOLatin1StringEncoding]];
      break;
    case IFExpressionTag_Num:
      *result = [IFConstantExpression expressionWithFloat:Double_val(Field(camlValue, 0))];
      break;
    case IFExpressionTag_Bool:
      *result = [IFConstantExpression expressionWithInt:Bool_val(Field(camlValue, 0))];
      break;
    case IFExpressionTag_Error:
      *result = [IFExpressionEvaluator invalidValue];
      break;
    default:
      abort();
      //NSAssert1(NO, @"unknown tag: %d",tag);
  }
  CAMLreturn0;
}

+ (id)expressionWithCamlValue:(value)camlValue;
{
  IFConstantExpression* result = nil;
  expressionWithCamlValue(camlValue, &result);
  return result;
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal2(block, contents);
  CAMLlocalN(args,4);
  int tag = -1;

  if (self == [IFExpressionEvaluator invalidValue]) {
    // TODO remove once errors are handled correctly
    tag = IFExpressionTag_Error;
    contents = Val_int(0);
  } else if ([object isKindOfClass:[NSString class]]) {
    tag = IFExpressionTag_String;
    contents = caml_copy_string([(NSString*)object cStringUsingEncoding:NSISOLatin1StringEncoding]);
  } else if ([object isKindOfClass:[NSValue class]]) {
    NSValue* val = (NSValue*)object;
    const char* objectType = [val objCType];
    if (strcmp(objectType,@encode(float)) == 0) {
      tag = IFExpressionTag_Num;
      contents = caml_copy_double([(NSNumber*)val floatValue]);
    } else if (strcmp(objectType,@encode(double)) == 0) {
      tag = IFExpressionTag_Num;
      contents = caml_copy_double([(NSNumber*)val doubleValue]);
    } else if (strcmp(objectType,@encode(NSPoint)) == 0) {
      tag = IFExpressionTag_Point;
      static value* pointMakeClosure = NULL;
      if (pointMakeClosure == NULL)
        pointMakeClosure = caml_named_value("Point.make");
      NSPoint p = [val pointValue];
      args[0] = caml_copy_double(p.x);
      args[1] = caml_copy_double(p.y);
      contents = caml_callback2(*pointMakeClosure, args[0], args[1]);      
    } else if (strcmp(objectType,@encode(NSRect)) == 0) {
      tag = IFExpressionTag_Rect;
      static value* rectMakeClosure = NULL;
      if (rectMakeClosure == NULL)
        rectMakeClosure = caml_named_value("Rect.make");
      NSRect r = [val rectValue];
      args[0] = caml_copy_double(NSMinX(r));
      args[1] = caml_copy_double(NSMinY(r));
      args[2] = caml_copy_double(NSWidth(r));
      args[3] = caml_copy_double(NSHeight(r));
      contents = caml_callbackN(*rectMakeClosure, 4, args);
    } else
      NSAssert2(NO, @"invalid value: %@ (type %s)",val,[val objCType]);  
  } else if ([object isKindOfClass:[NSColor class]]) {
    tag = IFExpressionTag_Color;
    static value* colorMakeClosure = NULL;
    if (colorMakeClosure == NULL)
      colorMakeClosure = caml_named_value("Color.make");
    NSColor* color = (NSColor*)object;
    args[0] = caml_copy_double([color redComponent]);
    args[1] = caml_copy_double([color greenComponent]);
    args[2] = caml_copy_double([color blueComponent]);
    args[3] = caml_copy_double([color alphaComponent]);
    contents = caml_callbackN(*colorMakeClosure, 4, args);
  } else
    NSAssert2(NO, @"invalid object: %@ (class %@)",object,[object class]);  

  NSAssert(tag != -1, @"invalid tag");
  block = caml_alloc(1, tag);
  Store_field(block, 0, contents);
  CAMLreturn(block);
}

@end
