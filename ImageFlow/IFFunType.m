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

- (NSArray*)argumentTypes;
{
  return argumentTypes;
}

- (IFType*)returnType;
{
  return returnType;
}

- (int)arity;
{
  return [argumentTypes count];
}

- (IFType*)typeByLimitingArityTo:(int)maxArity;
{
  return [self arity] > maxArity
  ? [IFFunType funTypeWithArgumentTypes:[argumentTypes subarrayWithRange:NSMakeRange(0,maxArity)] returnType:returnType]
  : self;
}

static value elemAsCaml(const char* elem) {
  return [(IFType*)elem asCaml];
}

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
