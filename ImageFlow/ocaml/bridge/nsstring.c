#include <objc/objc.h>
#include <objc/objc-runtime.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include "objc.h"

static id NSStringClass = NULL;

CAMLprim value NSString__stringWithUTF8String(value string) {
  CAMLparam1(string);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("stringWithUTF8String:");
  if (NSStringClass == NULL)
    NSStringClass = objc_getClass("NSString");
  CAMLreturn(objc_wrap(objc_msgSend(NSStringClass, sel, String_val(string))));
}

CAMLprim value NSString_lowercaseString(value self) {
  CAMLparam1(self);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("lowercaseString");
  CAMLreturn(objc_wrap(objc_msgSend(objc_unwrap(self), sel)));
}

CAMLprim value NSString_UTF8String(value self) {
  CAMLparam1(self);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("UTF8String");
  CAMLreturn(caml_copy_string((char*)objc_msgSend(objc_unwrap(self), sel)));
}
