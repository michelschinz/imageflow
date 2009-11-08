//
//  IFImageConstantExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageConstantExpression.h"
#import "IFExpressionTags.h"

#import "ocaml/bridge/objc.h"

#import <caml/callback.h>
#import <caml/memory.h>
#import <caml/alloc.h>

@implementation IFImageConstantExpression

+ (id)imageConstantExpressionWithIFImage:(IFImage*)theImage;
{
  return [[[self alloc] initWithObject:theImage tag:IFExpressionTag_Image] autorelease];
}

+ (id)imageConstantExpressionWithCIImage:(CIImage*)theImage;
{
  return [self imageConstantExpressionWithIFImage:[IFImage imageWithCIImage:theImage]];
}

+ (id)imageConstantExpressionWithCGImage:(CGImageRef)theImage;
{
  return [self imageConstantExpressionWithIFImage:[IFImage imageWithCGImage:theImage]];
}

- (IFImage*)image;
{
  return (IFImage*)object;
}

- (CIImage*)imageValueCI;
{
  // TODO: remove
  return [(IFImage*)object imageCI];
}

- (BOOL)isImage;
{
  return YES;
}

// MARK: Caml representation

- (value)camlRepresentation;
{
  CAMLparam0();
  CAMLlocal2(block, contents);
  static value* imageOfIFImageClosure = NULL;
  if (imageOfIFImageClosure == NULL)
    imageOfIFImageClosure = caml_named_value("Image.of_ifimage");
  contents = caml_callback(*imageOfIFImageClosure, objc_wrap(object));
  block = caml_alloc(1, [(IFImage*)object kind] == IFImageKindMask ? IFExpressionTag_Mask : IFExpressionTag_Image);
  Store_field(block, 0, contents);
  CAMLreturn(block);
}  

@end
