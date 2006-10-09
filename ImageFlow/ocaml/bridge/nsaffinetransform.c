#include <objc/objc.h>
#include <objc/objc-runtime.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

typedef struct _NSAffineTransformStruct {
    float m11, m12, m21, m22;
    float tX, tY;
} NSAffineTransformStruct;

static id NSAffineTransformClass = NULL;

CAMLprim value NSAffineTransform__transform() {
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("transform");
  if (NSAffineTransformClass == NULL)
    NSAffineTransformClass = objc_getClass("NSAffineTransform");
  return objc_wrap(objc_msgSend(NSAffineTransformClass, sel));
}

CAMLprim value NSAffineTransform_setTransformStruct(value self, value s) {
  CAMLparam2(self, s);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("setTransformStruct:");
  NSAffineTransformStruct nss = {
    Double_field(s, 0),
    Double_field(s, 1),
    Double_field(s, 2),
    Double_field(s, 3),
    Double_field(s, 4),
    Double_field(s, 5)
  };
  objc_msgSend(objc_unwrap(self), sel, nss);
  CAMLreturn(Val_unit);
}
