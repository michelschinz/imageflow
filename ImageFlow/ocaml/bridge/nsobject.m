#include <caml/mlvalues.h>
#include <caml/memory.h>

#include <Foundation/Foundation.h>

#include "objc.h"

CAMLprim value NSObject_retain(value self) {
  CAMLparam1(self);
  [objc_unwrap(self) retain];
  CAMLreturn(self);
}

CAMLprim value NSObject_release(value self) {
  CAMLparam1(self);
  [objc_unwrap(self) release];
  CAMLreturn(Val_unit);
}

CAMLprim value NSObject_retainCount(value self) {
  CAMLparam1(self);
  CAMLreturn(Val_int([objc_unwrap(self) retainCount]));
}

CAMLprim value NSObject_description(value self) {
  CAMLparam1(self);
  CAMLreturn(objc_wrap([objc_unwrap(self) description]));
}

CAMLprim value NSObject_isEqual(value self, value other) {
  CAMLparam2(self, other);
  CAMLreturn(Val_bool([objc_unwrap(self) isEqual:objc_unwrap(other)]));
}

CAMLprim value NSObject_hash(value self) {
  CAMLparam1(self);
  CAMLreturn(Val_int([objc_unwrap(self) hash]));
}
