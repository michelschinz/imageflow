#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>

#import "objc.h"

CAMLprim value NSMutableArray__array() {
  CAMLparam0();
  CAMLreturn(objc_wrap([NSMutableArray array]));
}

CAMLprim value NSMutableArray_addObject(value self, value object) {
  CAMLparam2(self, object);
  [objc_unwrap(self) addObject:objc_unwrap(object)];
  CAMLreturn(Val_unit);
}
