//
//  IFTypeVar.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTypeVar.h"

#import "IFTypeTags.h"
#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFTypeVar

+ (id)typeVarWithIndex:(int)theIndex;
{
  return [[[self alloc] initWithIndex:theIndex] autorelease];
}

- (id)initWithIndex:(int)theIndex;
{
  if (![super init])
    return nil;
  index = theIndex;
  return self;
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFTypeTag_TVar);
  Store_field(block, 0, Val_int(index));
  CAMLreturn(block);
}

@end
