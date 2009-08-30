//
//  IFImageType.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFImageType.h"
#import "IFBasicType.h"
#import "IFTypeTags.h"
#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFImageType


+ (id)imageRGBAType;
{
  static IFImageType* t = nil;
  if (t == nil)
    t = [self imageTypeWithPixelType:[IFBasicType colorRGBAType]];
  return t;
}

+ (id)maskType;
{
  static IFImageType* t = nil;
  if (t == nil)
    t = [self imageTypeWithPixelType:[IFBasicType floatType]];
  return t;
}

+ (id)imageTypeWithPixelType:(IFType*)thePixelType;
{
  return [[[self alloc] initWithPixelType:thePixelType] autorelease];
}

- (id)initWithPixelType:(IFType*)thePixelType;
{
  if (![super init])
    return nil;
  pixelType = [thePixelType retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(pixelType);
  [super dealloc];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"Image[%@]",pixelType];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[self class]] && [pixelType isEqual:[other pixelType]];
}

- (unsigned)hash;
{
  return [pixelType hash] * 2503;
}

- (IFType*)pixelType;
{
  return pixelType;
}

- (BOOL)isImageRGBAType;
{
  return pixelType == [IFBasicType colorRGBAType];
}

- (BOOL)isMaskType;
{
  return pixelType == [IFBasicType floatType];
}

- (unsigned)arity;
{
  return 0;
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFTypeTag_TImage);
  Store_field(block, 0, [pixelType asCaml]);
  CAMLreturn(block);
}

@end
