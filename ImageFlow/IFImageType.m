//
//  IFImageType.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFImageType.h"
#import "IFType.h"
#import "IFTypeTags.h"

#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFImageType

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

- (NSUInteger)hash;
{
  return [pixelType hash] * 2503;
}

- (IFType*)pixelType;
{
  return pixelType;
}

- (BOOL)isImageRGBAType;
{
  return pixelType == [IFType colorRGBAType];
}

- (BOOL)isMaskType;
{
  return pixelType == [IFType floatType];
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
