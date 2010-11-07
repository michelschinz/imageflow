//
//  IFConstantExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFConstantExpression.h"
#import "IFXMLCoder.h"
#import "IFExpressionTags.h"
#import "IFExpressionEvaluator.h"
#import "IFFileExportAction.h"

#import <caml/alloc.h>
#import <caml/memory.h>
#import <caml/callback.h>

#import "ocaml/bridge/objc.h"

static void expressionWithCamlValue(value camlValue, IFConstantExpression** result);

@interface IFConstantExpression ()
- (id)initWithTag:(int)theTag object:(id)theObject;
@end

@implementation IFConstantExpression

// MARK: Constructors

+ (id)expressionWithCamlValue:(value)camlValue;
{
  IFConstantExpression* result = nil;
  expressionWithCamlValue(camlValue, &result);
  return result;
}

+ (IFConstantExpression*)expressionWithObject:(id)theObject tag:(int)theTag;
{
  return [[[IFConstantExpression alloc] initWithTag:theTag object:theObject] autorelease];
}

+ (IFConstantExpression*)expressionWithArray:(NSArray*)theArray;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Array object:theArray] autorelease];
}

+ (IFConstantExpression*)expressionWithTupleElements:(NSArray*)theElements;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Tuple object:theElements] autorelease];
}

+ (IFConstantExpression*)expressionWithPointNS:(NSPoint)thePoint;
{
  return [IFConstantExpression expressionWithWrappedPointNS:[NSValue valueWithPoint:thePoint]];
}

+ (IFConstantExpression*)expressionWithWrappedPointNS:(NSValue*)thePoint;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Point object:thePoint] autorelease];
}

+ (IFConstantExpression*)expressionWithRectNS:(NSRect)theRect;
{
  return [IFConstantExpression expressionWithWrappedRectNS:[NSValue valueWithRect:theRect]];
}

+ (IFConstantExpression*)expressionWithWrappedRectNS:(NSValue*)thePoint;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Rect object:thePoint] autorelease];
}

+ (IFConstantExpression*)expressionWithRectCG:(CGRect)theRect;
{
  return [self expressionWithRectNS:NSRectFromCGRect(theRect)];
}

+ (IFConstantExpression*)expressionWithColorNS:(NSColor*)theColor;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Color object:theColor] autorelease];
}

+ (IFConstantExpression*)expressionWithString:(NSString*)theString;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_String object:theString] autorelease];
}

+ (IFConstantExpression*)expressionWithInt:(int)theInt;
{
  return [IFConstantExpression expressionWithWrappedInt:[NSNumber numberWithInt:theInt]];
}

+ (IFConstantExpression*)expressionWithWrappedInt:(NSNumber*)theInt;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Int object:theInt] autorelease];
}

+ (IFConstantExpression*)expressionWithFloat:(float)theFloat;
{
  return [IFConstantExpression expressionWithWrappedFloat:[NSNumber numberWithFloat:theFloat]];
}

+ (IFConstantExpression*)expressionWithWrappedFloat:(NSNumber*)theFloat;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Num object:theFloat] autorelease];
}

+ (IFConstantExpression*)exportActionWithFileURL:(NSURL*)theFileURL image:(CIImage*)theImage exportArea:(CGRect)theExportArea;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Action object:[IFFileExportAction exportActionWithFileURL:theFileURL image:theImage exportArea:theExportArea]] autorelease];
}

+ (IFConstantExpression*)imageConstantExpressionWithIFImage:(IFImage*)theImage;
{
  return [[(IFConstantExpression*)[IFConstantExpression alloc] initWithTag:(theImage.kind == IFImageKindRGBImage ? IFExpressionTag_Image : IFExpressionTag_Mask) object:theImage] autorelease];
}

+ (id)errorConstantExpressionWithMessage:(NSString*)theMessage;
{
  return [[[IFConstantExpression alloc] initWithTag:IFExpressionTag_Error object:theMessage] autorelease];
}

- (id)initWithTag:(int)theTag object:(id)theObject;
{
  if (![super init])
    return nil;
  tag = theTag;
  object = [theObject retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(object);
  [super dealloc];
}

// MARK: Predicates

- (BOOL)isArray;
{
  return self.tag == IFExpressionTag_Array;
}

- (BOOL)isImage;
{
  return self.tag == IFExpressionTag_Image || self.tag == IFExpressionTag_Mask;
}

- (BOOL)isAction;
{
  return self.tag == IFExpressionTag_Action;
}

- (BOOL)isError;
{
  return self.tag == IFExpressionTag_Error;
}

// MARK: Properties

@synthesize tag, object;

- (NSString*)description;
{
  return [object description];
}

- (IFImage*)imageValue;
{
  NSAssert(tag == IFExpressionTag_Mask || tag == IFExpressionTag_Image, @"object is not an image/mask: %@", object);
  return object;
}

- (NSArray*)arrayValue;
{
  NSAssert1(tag == IFExpressionTag_Array, @"object is not an array: %@",object);
  return object;
}

- (NSArray*)flatArrayValue;
{
  NSArray* array = [self arrayValue];
  if ([array count] == 0 || ![[array objectAtIndex:0] isArray])
    return array;
  else {
    NSMutableArray* flattenedArray = [NSMutableArray array];
    for (IFConstantExpression* elem in array)
      [flattenedArray addObjectsFromArray:[elem flatArrayValue]];
    return flattenedArray;
  }
}

- (NSArray*)tupleValue;
{
  NSAssert(tag == IFExpressionTag_Tuple, @"object is not a tuple: %@", object);
  return (NSArray*)object;
}

- (NSPoint)pointValueNS;
{
  NSAssert1(tag == IFExpressionTag_Point, @"object is not a value: %@",object);
  NSValue* value = (NSValue*)object;
  NSAssert1(strcmp([value objCType],@encode(NSPoint)) == 0, @"object is not a point: %@",object);
  return [value pointValue];
}

- (NSRect)rectValueNS;
{
  NSAssert1(tag == IFExpressionTag_Rect, @"object is not a value: %@",object);
  NSValue* value = (NSValue*)object;
  NSAssert1(strcmp([value objCType],@encode(NSRect)) == 0, @"object is not a rectangle: %@",object);
  return [value rectValue];
}

- (CGRect)rectValueCG;
{
  return NSRectToCGRect([self rectValueNS]);
}

- (NSColor*)colorValueNS;
{
  NSAssert1(tag == IFExpressionTag_Color, @"object is not a color (NS): %@",object);
  return object;
}

- (CIColor*)colorValueCI;
{
  NSAssert1(tag == IFExpressionTag_Color, @"object is not a color (NS): %@",object);
  return [[[CIColor alloc] initWithColor:object] autorelease];
}

- (NSString*)stringValue;
{
  NSAssert1(tag == IFExpressionTag_String, @"object is not a string: %@",object);
  return object;
}

- (BOOL)boolValue;
{
  NSAssert1(tag == IFExpressionTag_Bool, @"object is not a boolean: %@",object);
  return [object boolValue];
}

- (int)intValue;
{
  NSAssert1(tag == IFExpressionTag_Int, @"object is not an integer: %@",object);
  return [object intValue];
}

- (float)floatValue;
{
  NSAssert1(IFExpressionTag_Num, @"object is not a float: %@",object);
  return [object floatValue];
}

- (NSUInteger)hash;
{
  return [object hash];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[IFConstantExpression class]] && [object isEqual:((IFConstantExpression*)other).object];
}

// MARK: XML input/output

- (id)initWithXML:(NSXMLElement*)xml;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  int decodedTag = [xmlCoder decodeInt:[[xml attributeForName:@"typeTag"] stringValue]];
  id decodedObject = nil;
  switch (decodedTag) {
    case IFExpressionTag_Array:
    case IFExpressionTag_Tuple:
      NSAssert(NO, @"not implemented yet"); // FIXME: implement

    case IFExpressionTag_Color:
      decodedObject = [xmlCoder decodeColor:[xml stringValue]];
      break;

    case IFExpressionTag_Rect:
      decodedObject = [NSValue valueWithRect:[xmlCoder decodeRect:[xml stringValue]]];
      break;

    case IFExpressionTag_Point:
      decodedObject = [NSValue valueWithPoint:[xmlCoder decodePoint:[xml stringValue]]];
      break;

    case IFExpressionTag_String:
      decodedObject = [xmlCoder decodeString:[xml stringValue]];
      break;

    case IFExpressionTag_Num:
      decodedObject = [NSNumber numberWithFloat:[xmlCoder decodeFloat:[xml stringValue]]];
      break;

    case IFExpressionTag_Int:
    case IFExpressionTag_Bool:
      decodedObject = [NSNumber numberWithInt:[xmlCoder decodeInt:[xml stringValue]]];
      break;

    default:
      NSAssert(NO, @"invalid tag %d", tag);
      break;
  }
  return [self initWithTag:decodedTag object:decodedObject];
}

- (NSXMLElement*)asXML;
{
  IFXMLCoder* xmlCoder = [IFXMLCoder sharedCoder];
  NSXMLElement* elem = [NSXMLElement elementWithName:@"constant"];
  [elem addAttribute:[NSXMLNode attributeWithName:@"typeTag" stringValue:[xmlCoder encodeInt:tag]]];
  switch (tag) {
    case IFExpressionTag_Array:
    case IFExpressionTag_Tuple:
      NSAssert(NO, @"not implemented yet"); // FIXME: implement

    case IFExpressionTag_Color:
      [elem setStringValue:[xmlCoder encodeColor:[self colorValueNS]]];
      break;

    case IFExpressionTag_Rect:
      [elem setStringValue:[xmlCoder encodeRect:[self rectValueNS]]];
      break;

    case IFExpressionTag_Point:
      [elem setStringValue:[xmlCoder encodePoint:[self pointValueNS]]];
      break;

    case IFExpressionTag_String:
      [elem setStringValue:[xmlCoder encodeString:[self stringValue]]];
      break;

    case IFExpressionTag_Num:
      [elem setStringValue:[xmlCoder encodeFloat:[self floatValue]]];
      break;

    case IFExpressionTag_Int:
      [elem setStringValue:[xmlCoder encodeInt:[self intValue]]];
      break;

    case IFExpressionTag_Bool:
      [elem setStringValue:[xmlCoder encodeInt:[self boolValue]]];
      break;

    default:
      NSAssert(NO, @"unknown tag %d", tag);
      break;
  }
  return elem;
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder*)decoder;
{
  return [self initWithTag:[decoder decodeIntForKey:@"tag"] object:[decoder decodeObjectForKey:@"object"]];
}

- (void)encodeWithCoder:(NSCoder*)encoder;
{
  [encoder encodeInt:tag forKey:@"tag"];
  [encoder encodeObject:object forKey:@"object"];
}

// MARK: Caml representation

static value elemAsCaml(const char* elem) {
  return [(IFExpression*)elem asCaml];
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal2(block, contents);
  CAMLlocalN(args,4);

  switch (tag) {
    case IFExpressionTag_String:
      NSAssert([object isKindOfClass:[NSString class]], @"invalid object");
      contents = caml_copy_string([(NSString*)object cStringUsingEncoding:NSISOLatin1StringEncoding]);
      break;

    case IFExpressionTag_Int:
      NSAssert([object isKindOfClass:[NSNumber class]], @"invalid object");
      contents = Val_int([(NSNumber*)object intValue]);
      break;

    case IFExpressionTag_Num:
      NSAssert([object isKindOfClass:[NSNumber class]], @"invalid object");
      contents = caml_copy_double([(NSNumber*)object doubleValue]);
      break;

    case IFExpressionTag_Point: {
      NSAssert([object isKindOfClass:[NSValue class]], @"invalid object");
      static value* pointMakeClosure = NULL;
      if (pointMakeClosure == NULL)
        pointMakeClosure = caml_named_value("Point.make");
      NSPoint p = [(NSValue*)object pointValue];
      args[0] = caml_copy_double(p.x);
      args[1] = caml_copy_double(p.y);
      contents = caml_callback2(*pointMakeClosure, args[0], args[1]);
    } break;

    case IFExpressionTag_Rect: {
      NSAssert([object isKindOfClass:[NSValue class]], @"invalid object");
      static value* rectMakeClosure = NULL;
      if (rectMakeClosure == NULL)
        rectMakeClosure = caml_named_value("Rect.make");
      NSRect r = [(NSValue*)object rectValue];
      args[0] = caml_copy_double(NSMinX(r));
      args[1] = caml_copy_double(NSMinY(r));
      args[2] = caml_copy_double(NSWidth(r));
      args[3] = caml_copy_double(NSHeight(r));
      contents = caml_callbackN(*rectMakeClosure, 4, args);
    } break;

    case IFExpressionTag_Color: {
      NSAssert([object isKindOfClass:[NSColor class]], @"invalid object");
      static value* colorMakeClosure = NULL;
      if (colorMakeClosure == NULL)
        colorMakeClosure = caml_named_value("Color.make");
      NSColor* color = [(NSColor*)object colorUsingColorSpaceName:NSCalibratedRGBColorSpace]; // TODO use correct color space
      args[0] = caml_copy_double([color redComponent]);
      args[1] = caml_copy_double([color greenComponent]);
      args[2] = caml_copy_double([color blueComponent]);
      args[3] = caml_copy_double([color alphaComponent]);
      contents = caml_callbackN(*colorMakeClosure, 4, args);
    } break;

    case IFExpressionTag_Array:
    case IFExpressionTag_Tuple: {
      NSAssert([object isKindOfClass:[NSArray class]], @"invalid object");
      NSArray* array = (NSArray*)object;
      IFExpression** cArray = malloc(([array count] + 1) * sizeof(IFExpression*));
      [array getObjects:cArray];
      cArray[[array count]] = NULL;
      contents = caml_alloc_array(elemAsCaml, (char const**)cArray);
      free(cArray);
    } break;

    case IFExpressionTag_Image:
    case IFExpressionTag_Mask: {
      NSAssert([object isKindOfClass:[IFImage class]], @"invalid object");
      static value* imageOfIFImageClosure = NULL;
      if (imageOfIFImageClosure == NULL)
        imageOfIFImageClosure = caml_named_value("Image.of_ifimage");
      contents = caml_callback(*imageOfIFImageClosure, objc_wrap(object));
    } break;

    case IFExpressionTag_Error: {
      if (object != nil) {
        contents = caml_alloc(1, 1);
        Store_field(contents, 0, caml_copy_string([object cStringUsingEncoding:NSISOLatin1StringEncoding]));
      } else
        contents = Val_int(0);
    } break;

    default:
      NSAssert(NO, @"unknown tag %d", tag);
      break;
  }

  block = caml_alloc(1, tag);
  Store_field(block, 0, contents);
  CAMLreturn(block);
}

@end

static void expressionWithCamlValue(value camlValue, IFConstantExpression** result) {
  CAMLparam1(camlValue);
  CAMLlocal1(contents);
  IFExpressionTag tag = Tag_val(camlValue);
  switch (tag) {
    case IFExpressionTag_Array: {
      contents = Field(camlValue, 0);
      NSMutableArray* array = [NSMutableArray arrayWithCapacity:Wosize_val(contents)];
      for (int i = 0; i < Wosize_val(contents); ++i) {
        IFConstantExpression* elemExpression;
        expressionWithCamlValue(Field(contents, i), &elemExpression);
        [array addObject:elemExpression];
      }
      *result = [IFConstantExpression expressionWithArray:array];
    } break;

    case IFExpressionTag_Tuple: {
      contents = Field(camlValue, 0);
      NSMutableArray* array = [NSMutableArray arrayWithCapacity:Wosize_val(contents)];
      for (int i = 0; i < Wosize_val(contents); ++i) {
        IFConstantExpression* elemExpression;
        expressionWithCamlValue(Field(contents, i), &elemExpression);
        [array addObject:elemExpression];
      }
      *result = [IFConstantExpression expressionWithTupleElements:array];
    } break;

    case IFExpressionTag_Mask:
    case IFExpressionTag_Image: {
      static value* imageToIFImageClosure = NULL;
      if (imageToIFImageClosure == NULL)
        imageToIFImageClosure = caml_named_value("Image.to_ifimage");
      contents = caml_callback(*imageToIFImageClosure,Field(camlValue,0));
      *result = [IFConstantExpression imageConstantExpressionWithIFImage:objc_unwrap(contents)];
    } break;

    case IFExpressionTag_Color: {
      NSLog(@"TODO color");
      *result = nil;
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
      *result = [IFConstantExpression expressionWithString:[NSString stringWithCString:String_val(Field(camlValue, 0)) encoding:NSISOLatin1StringEncoding]];
      break;
    case IFExpressionTag_Num:
      *result = [IFConstantExpression expressionWithFloat:Double_val(Field(camlValue, 0))];
      break;
    case IFExpressionTag_Int:
      *result = [IFConstantExpression expressionWithInt:Int_val(Field(camlValue, 0))];
      break;
    case IFExpressionTag_Bool:
      *result = [IFConstantExpression expressionWithInt:Bool_val(Field(camlValue, 0))];
      break;
    case IFExpressionTag_Action:
      *result = objc_unwrap(Field(camlValue, 0));
      break;
    case IFExpressionTag_Error: {
      NSString* msg = (Field(camlValue, 0) == Val_int(0/*None*/))
      ? nil
      : [NSString stringWithCString:String_val(Field(Field(camlValue,0),0)) encoding:NSISOLatin1StringEncoding];
      *result = [IFConstantExpression errorConstantExpressionWithMessage:msg];
    } break;
    default:
      NSCAssert1(NO, @"unknown tag: %d", tag);
  }
  CAMLreturn0;
}
