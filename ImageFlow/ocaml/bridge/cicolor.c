#include <objc/objc.h>
#include <objc/objc-runtime.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

static id CIColorClass = NULL;

CAMLprim value CIColor__colorWithRedGreenBlueAlpha(value r, value g, value b, value a) {
  CAMLparam4(r, g, b, a);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("colorWithRed:green:blue:alpha:");
  if (CIColorClass == NULL)
    CIColorClass = objc_getClass("CIColor");
  CAMLreturn(objc_wrap(objc_msgSend(CIColorClass, sel, Double_val(r), Double_val(g), Double_val(b), Double_val(a))));
}

