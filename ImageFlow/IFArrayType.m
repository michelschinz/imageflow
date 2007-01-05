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

- (NSString*)description;
{
  return [[contentType description] stringByAppendingString:@"[]"];
}

- (int)arity;
{
  return 0;
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
