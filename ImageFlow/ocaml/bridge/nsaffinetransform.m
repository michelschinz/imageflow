#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>

#import "objc.h"

CAMLprim value NSAffineTransform__transform() {
  return objc_wrap([NSAffineTransform transform]);
}

CAMLprim value NSAffineTransform_setTransformStruct(value self, value s) {
  CAMLparam2(self, s);
  NSAffineTransformStruct nss = {
    Double_field(s, 0),
    Double_field(s, 1),
    Double_field(s, 2),
    Double_field(s, 3),
    Double_field(s, 4),
    Double_field(s, 5)
  };
  [objc_unwrap(self) setTransformStruct:nss];
  CAMLreturn(Val_unit);
}
