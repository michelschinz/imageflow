#include <assert.h>

#include <objc/objc.h>
#include <objc/objc-runtime.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include <ApplicationServices/ApplicationServices.h>

#include "objc.h"
#include "corefoundation.h"

static id CIImageClass = NULL;

CAMLprim value CIImage__imageWithCGImage(value wrapped_cgimage) {
  CAMLparam1(wrapped_cgimage);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("imageWithCGImage:");
  if (CIImageClass == NULL)
    CIImageClass = objc_getClass("CIImage");
  CGImageRef cgImage = (CGImageRef)cf_unwrap(wrapped_cgimage);
  assert(cgImage != NULL);
  CAMLreturn(objc_wrap(objc_msgSend(CIImageClass, sel, cgImage)));
}

CAMLprim value CIImage_extent(value self) {
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
