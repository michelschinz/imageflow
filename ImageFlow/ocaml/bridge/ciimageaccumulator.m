#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/alloc.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "objc.h"

CAMLprim value CIImageAccumulator__imageAccumulatorWithExtent(value extent) {
  CAMLparam1(extent);
  CGRect r = CGRectMake(Double_field(extent, 0),
                        Double_field(extent, 1),
                        Double_field(extent, 2),
                        Double_field(extent, 3));
  CAMLreturn(objc_wrap([CIImageAccumulator imageAccumulatorWithExtent:r
                                           format:kCIFormatARGB8]));
}

CAMLprim value CIImageAccumulator_extent(value self) {
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

CAMLprim value CIImageAccumulator_setImage(value self, value image) {
  CAMLparam2(self, image);
  [objc_unwrap(self) setImage:objc_unwrap(image)];
  CAMLreturn(Val_unit);
}

CAMLprim value CIImageAccumulator_image(value self) {
  CAMLparam1(self);
  CAMLreturn(objc_wrap([objc_unwrap(self) image]));
}
