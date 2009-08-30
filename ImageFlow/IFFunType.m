//
//  IFFunType.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFFunType.h"

#import "IFTypeTags.h"
#import <caml/alloc.h>
#import <caml/memory.h>

@implementation IFFunType

+ (id)funTypeWithArgumentTypes:(NSArray*)theArgTypes returnType:(IFType*)theRetType;
{
  return [[[self alloc] initWithArgumentTypes:theArgTypes returnType:theRetType] autorelease];
}

- (id)initWithArgumentTypes:(NSArray*)theArgTypes returnType:(IFType*)theRetType;
{
  if (![super init])
    return nil;
  argumentTypes = [theArgTypes retain];
  returnType = [theRetType retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(returnType);
  OBJC_RELEASE(argumentTypes);
  [super dealloc];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"(%@)=>%@",[argumentTypes componentsJoinedByString:@","],returnType];
}

- (BOOL)isEqual:(id)other;
{
  if ([other isKindOfClass:[self class]]) {
    NSArray* otherArgTypes = [other argumentTypes];
    if ([otherArgTypes count] != [argumentTypes count])
      return false;
    for (int i = 0, count = [argumentTypes count]; i < count; ++i)
      if (![[argumentTypes objectAtIndex:i] isEqual:[otherArgTypes objectAtIndex:i]])
        return false;
    return [returnType isEqual:[other returnType]];
  } else
    return false;
}

- (unsigned)hash;
{
  unsigned hash = 7;
  for (int i = 0, count = [argumentTypes count]; i < count; ++i)
    hash = hash * 1973 + [[argumentTypes objectAtIndex:i] hash];
  hash ^= [returnType hash];
  return hash;
}

- (NSArray*)argumentTypes;
{
  return argumentTypes;
}

- (IFType*)returnType;
{
  return returnType;
}

- (unsigned)arity;
{
  return [argumentTypes count];
}

- (IFType*)resultType;
{
  return returnType;
}

static value elemAsCaml(const char* elem) {
  return [(IFType*)elem asCaml];
}

// MARK: -
// MARK: PROTECTED

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal1(block);
  block = caml_alloc(2, IFTypeTag_TFun);
  IFType** cArray = malloc(([argumentTypes count] + 1) * sizeof(IFType*));
  [argumentTypes getObjects:cArray];
  cArray[[argumentTypes count]] = NULL;
  Store_field(block, 0, caml_alloc_array(elemAsCaml, (char const**)cArray));
  Store_field(block, 1, [returnType asCaml]);
  CAMLreturn(block);
}

@end
