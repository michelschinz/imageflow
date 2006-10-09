#include <assert.h>
#include <objc/objc.h>
#include <objc/objc-runtime.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

static id CIFilterClass = NULL;

CAMLprim value CIFilter__filterWithName(value name) {
  CAMLparam1(name);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("filterWithName:");
  if (CIFilterClass == NULL) {
    CIFilterClass = objc_getClass("CIFilter");
    assert(CIFilterClass != NULL);
  }
  CAMLreturn(objc_wrap(objc_msgSend(CIFilterClass, sel, objc_unwrap(name))));
}

CAMLprim value CIFilter_setValueForKey(value self, value val, value key) {
  CAMLparam3(self, val, key);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("setValue:forKey:");
  objc_msgSend(objc_unwrap(self), sel, objc_unwrap(val), objc_unwrap(key));
  CAMLreturn(Val_unit);
}

CAMLprim value CIFilter_valueForKey(value self, value key) {
  CAMLparam2(self, key);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("valueForKey:");
  CAMLreturn(objc_wrap(objc_msgSend(objc_unwrap(self), sel, objc_unwrap(key))));
}
