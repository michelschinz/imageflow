//
//  IFFunType.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFFunType.h"
#import "IFTupleType.h"

#import "IFTypeTags.h"
#import <caml/alloc.h>
#import <caml/memory.h>

@implementation IFFunType

- (id)initWithArgumentType:(IFType*)theArgType returnType:(IFType*)theRetType;
{
  if (![super init])
    return nil;
  argumentType = [theArgType retain];
  returnType = [theRetType retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(returnType);
  OBJC_RELEASE(argumentType);
  [super dealloc];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"%@=>%@",argumentType,returnType];
}

- (BOOL)isEqual:(id)other;
{
  return ([other isKindOfClass:[self class]]
          && [argumentType isEqual:[other argumentType]]
          && [returnType isEqual:[other returnType]]);
}

- (NSUInteger)hash;
{
  return [argumentType hash] ^ [returnType hash];
}

@synthesize argumentType, returnType;

- (BOOL)isFunType;
{
  return YES;
}

- (unsigned)arity;
{
  if (argumentType.isTupleType)
    return [((IFTupleType*)argumentType).componentTypes count];
  else
    return 1;
}

- (IFType*)resultType;
{
  return returnType;
}

// MARK: -
// MARK: PROTECTED

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(2, IFTypeTag_TFun);
  Store_field(block, 0, [argumentType asCaml]);
  Store_field(block, 1, [returnType asCaml]);
  CAMLreturn(block);
}

@end
