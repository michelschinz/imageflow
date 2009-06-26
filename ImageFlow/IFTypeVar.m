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

// TODO: remove index and use object identity instead (if possible)

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

- (NSString*)description;
{
  return [NSString stringWithFormat:@"'t%d",index];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[IFTypeVar class]] && index == ((IFTypeVar*)other)->index;
}

- (unsigned)hash;
{
  return index;
}

- (int)arity;
{
  return 0;
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
