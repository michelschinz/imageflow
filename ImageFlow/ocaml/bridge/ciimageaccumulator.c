#include <objc/objc.h>
#include <objc/objc-runtime.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include <ApplicationServices/ApplicationServices.h>

#include "objc.h"
#include "corefoundation.h"

static id CIImageAccumulatorClass = NULL;

CAMLprim value CIImageAccumulator__imageAccumulatorWithExtent(value extent) {
  CAMLparam1(extent);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("imageAccumulatorWithExtent:");
  if (CIImageAccumulatorClass == NULL)
    CIImageAccumulatorClass = objc_getClass("CIImageAccumulator");
  CGRect r = CGRectMake(Double_field(extent, 0),
                        Double_field(extent, 1),
                        Double_field(extent, 2),
                        Double_field(extent, 3));
  CAMLreturn(objc_wrap(objc_msgSend(CIImageAccumulatorClass, sel, r)));
}

CAMLprim value CIImageAccumulator_extent(value self) {
  CAMLparam1(self);
  CAMLlocal1 (camlExtent);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("extent");
  CGRect extent;
  objc_msgSend_stret(&extent, objc_unwrap(self), sel);
  camlExtent = caml_alloc(4 * Double_wosize, Double_array_tag);
  Store_double_field(camlExtent, 0, CGRectGetMinX(extent));
  Store_double_field(camlExtent, 1, CGRectGetMinY(extent));
  Store_double_field(camlExtent, 2, CGRectGetWidth(extent));
  Store_double_field(camlExtent, 3, CGRectGetHeight(extent));
  CAMLreturn(camlExtent);
}

CAMLprim value CIImageAccumulator_setImage(value self, value image) {
  CAMLparam2(self, image);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("setImage:");
  objc_msgSend(objc_unwrap(self), sel, objc_unwrap(image));
  CAMLreturn(Val_unit);
}

CAMLprim value CIImageAccumulator_image(value self) {
  CAMLparam1(self);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("image");
  CAMLreturn(objc_wrap(objc_msgSend(objc_unwrap(self), sel)));
}
