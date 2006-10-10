#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/alloc.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "objc.h"
#import "corefoundation.h"

CAMLprim value CIImage__imageWithCGImage(value wrapped_cgimage) {
  CAMLparam1(wrapped_cgimage);
  CAMLreturn(objc_wrap([CIImage imageWithCGImage:cf_unwrap(wrapped_cgimage)]));
}

CAMLprim value CIImage_extent(value self) {
  CAMLparam1(self);
  CAMLlocal1 (camlExtent);
  CGRect extent = [objc_unwrap(self) extent];
  camlExtent = caml_alloc(4 * Double_wosize, Double_array_tag);
  Store_double_field(camlExtent, 0, CGRectGetMinX(extent));
  Store_double_field(camlExtent, 1, CGRectGetMinY(extent));
  Store_double_field(camlExtent, 2, CGRectGetWidth(extent));
  Store_double_field(camlExtent, 3, CGRectGetHeight(extent));
  CAMLreturn(camlExtent);
}
