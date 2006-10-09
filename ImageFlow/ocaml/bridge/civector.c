#include <objc/objc.h>
#include <objc/objc-runtime.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

static id CIVectorClass = NULL;

CAMLprim value CIVector__vectorWithXYZW(value x, value y, value z, value w) {
  CAMLparam4(x, y, z, w);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("vectorWithX:Y:Z:W:");
  if (CIVectorClass == NULL)
    CIVectorClass = objc_getClass("CIVector");
  CAMLreturn(objc_wrap(objc_msgSend(CIVectorClass, sel, Double_val(x), Double_val(y), Double_val(z), Double_val(w))));
}

