//
//  IFArrayType.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFArrayType.h"

#import "IFTypeTags.h"
#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFArrayType

+ (id)arrayTypeWithContentType:(IFType*)theContentType;
{
  return [[[self alloc] initWithContentType:theContentType] autorelease];
}

- (id)initWithContentType:(IFType*)theContentType;
{
  if (![super init])
    return nil;
  contentType = [theContentType retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(contentType);
  [super dealloc];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"Array[%@]", [contentType description]];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[self class]] && [contentType isEqual:[other contentType]];
}

- (unsigned)hash;
{
  return [contentType hash] * 5101;
}

- (BOOL)isArrayType;
{
  return YES;
}

- (IFType*)contentType;
{
  return contentType;
}

- (unsigned)arity;
{
  return 0;
}

- (IFType*)leafType;
{
  return contentType.leafType;
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFTypeTag_TArray);
  Store_field(block, 0, [contentType asCaml]);
  CAMLreturn(block);
}

@end
