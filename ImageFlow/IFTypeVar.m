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

@interface IFTypeVar ()
- (id)initWithIndex:(int)theIndex;
@end


@implementation IFTypeVar

+ (id)typeVar;
{
  static int currentIndex = 0;
  return [[(IFTypeVar*)[self alloc] initWithIndex:currentIndex++] autorelease];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"'t%d",index];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[IFTypeVar class]] && index == ((IFTypeVar*)other)->index;
}

- (NSUInteger)hash;
{
  return index;
}

- (unsigned)arity;
{
  return 0;
}

// MARK: -
// MARK: PROTECTED

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(1, IFTypeTag_TVar);
  Store_field(block, 0, Val_int(index));
  CAMLreturn(block);
}

// MARK: -
// MARK: PRIVATE

- (id)initWithIndex:(int)theIndex;
{
  if (![super init])
    return nil;
  index = theIndex;
  return self;
}

@end
