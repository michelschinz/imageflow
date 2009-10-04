//
//  IFErrorConstantExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFErrorConstantExpression.h"
#import "IFExpressionTags.h"

#import "ocaml/bridge/objc.h"

#import <caml/callback.h>
#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFErrorConstantExpression

+ (id)errorConstantExpressionWithMessage:(NSString*)theMessage;
{
  return [[[self alloc] initWithObject:theMessage tag:IFExpressionTag_Mask] autorelease];
}

- (NSString*)message;
{
  return (NSString*)object;
}

- (BOOL)isError;
{
  return YES;
}

static const int tag_None = 0, tag_Some = 0;

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal2(block, contents);
  block = caml_alloc(1, IFExpressionTag_Error);
  if (object != nil) {
    contents = caml_alloc(1, tag_Some);
    Store_field(contents, 0, caml_copy_string([(NSString*)object cStringUsingEncoding:NSISOLatin1StringEncoding]));
  } else
    contents = Val_int(tag_None);
  Store_field(block, 0, contents);
  CAMLreturn(block);  
}

@end
