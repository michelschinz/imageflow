#include <objc/objc.h>
#include <objc/objc-runtime.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

static id NSNumberClass = NULL;

CAMLprim value NSNumber__numberWithDouble(value theDouble) {
  CAMLparam1(theDouble);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("numberWithDouble:");
  if (NSNumberClass == NULL)
    NSNumberClass = objc_getClass("NSNumber");
  CAMLreturn(objc_wrap(objc_msgSend(NSNumberClass, sel, Double_val(theDouble))));
}

