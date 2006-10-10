#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "objc.h"

CAMLprim value CIFilter__filterWithName(value name) {
  CAMLparam1(name);
  CAMLreturn(objc_wrap([CIFilter filterWithName:objc_unwrap(name)]));
}

CAMLprim value CIFilter_setValueForKey(value self, value val, value key) {
  CAMLparam3(self, val, key);
  [objc_unwrap(self) setValue:objc_unwrap(val) forKey:objc_unwrap(key)];
  CAMLreturn(Val_unit);
}

CAMLprim value CIFilter_valueForKey(value self, value key) {
  CAMLparam2(self, key);
  CAMLreturn(objc_wrap([objc_unwrap(self) valueForKey:objc_unwrap(key)]));
}
