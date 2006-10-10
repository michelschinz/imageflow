#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>

#import "objc.h"

CAMLprim value NSNumber__numberWithDouble(value theDouble) {
  CAMLparam1(theDouble);
  CAMLreturn(objc_wrap([NSNumber numberWithDouble:Double_val(theDouble)]));
}
