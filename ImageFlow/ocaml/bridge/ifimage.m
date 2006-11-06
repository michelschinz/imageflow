#import <Foundation/Foundation.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/alloc.h>

#import "objc.h"
#import "corefoundation.h"
#import "IFImage.h"

CAMLprim value IFImage__emptyImage() {
  return objc_wrap([IFImage emptyImage]);
}

CAMLprim value IFImage__imageWithCGImage(value cgimage) {
  CAMLparam1(cgimage);
  CAMLreturn(objc_wrap([IFImage imageWithCGImage:(CGImageRef)cf_unwrap(cgimage)]));
}

CAMLprim value IFImage__imageWithCIImage(value ciimage) {
  CAMLparam1(ciimage);
  CAMLreturn(objc_wrap([IFImage imageWithCIImage:objc_unwrap(ciimage)]));
}

CAMLprim value IFImage__maskWithCIImage(value ciimage) {
  CAMLparam1(ciimage);
  CAMLreturn(objc_wrap([IFImage maskWithCIImage:objc_unwrap(ciimage)]));
}

CAMLprim value IFImage_extent(value self) {
  CAMLparam1(self);
  CAMLlocal1(camlExtent);
  CGRect extent = [objc_unwrap(self) extent];
  camlExtent = caml_alloc(4 * Double_wosize, Double_array_tag);
  Store_double_field(camlExtent, 0, CGRectGetMinX(extent));
  Store_double_field(camlExtent, 1, CGRectGetMinY(extent));
  Store_double_field(camlExtent, 2, CGRectGetWidth(extent));
  Store_double_field(camlExtent, 3, CGRectGetHeight(extent));
  CAMLreturn(camlExtent);
}

CAMLprim value IFImage_imageCI(value self) {
  CAMLparam1(self);
  CAMLreturn(objc_wrap([objc_unwrap(self) imageCI]));
}

CAMLprim value IFImage_isLocked(value self) {
  CAMLparam1(self);
  CAMLreturn(Val_bool([objc_unwrap(self) isLocked]));
}

CAMLprim value IFImage_logRetainCounts(value self) {
  CAMLparam1(self);
  [objc_unwrap(self) logRetainCounts];
  CAMLreturn(Val_unit);
}

