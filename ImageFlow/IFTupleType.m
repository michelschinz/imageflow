//
//  IFTupleType.m
//  ImageFlow
//
//  Created by Michel Schinz on 27.09.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFTupleType.h"

#import "IFTypeTags.h"
#import <caml/alloc.h>
#import <caml/memory.h>

@implementation IFTupleType

- (id)initWithComponentTypes:(NSArray*)theComponentTypes;
{
  if (![super init])
    return nil;
  NSAssert([theComponentTypes count] >= 2, @"invalid tuple type");
  componentTypes = [theComponentTypes retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(componentTypes);
  [super dealloc];
}

- (NSString*)description;
{
  return [NSString stringWithFormat:@"(%@)", [componentTypes componentsJoinedByString:@","]];
}

- (BOOL)isEqual:(id)other;
{
  return [other isKindOfClass:[self class]] && [componentTypes isEqual:[other componentTypes]];
}

- (NSUInteger)hash;
{
  NSUInteger hash = 17;
  for (IFType* componentType in componentTypes)
    hash = (hash * 3) ^ [componentType hash];
  return hash;
}

- (BOOL)isTupleType;
{
  return YES;
}

@synthesize componentTypes;

static value elemAsCaml(const char* elem) {
  return [(IFType*)elem asCaml];
}

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal3(block, head, cell);
  head = Val_int(0);
  for (IFType* componentType in [componentTypes reverseObjectEnumerator]) {
    cell = caml_alloc(2, 0);
    Store_field(cell, 0, [componentType asCaml]);
    Store_field(cell, 1, head);
    head = cell;
  }
  block = caml_alloc(1, IFTypeTag_TTuple);
  Store_field(block, 0, head);
  CAMLreturn(block);
}

@end
