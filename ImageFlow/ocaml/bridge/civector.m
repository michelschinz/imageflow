#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "objc.h"

CAMLprim value CIVector__vectorWithXYZW(value x, value y, value z, value w) {
  CAMLparam4(x, y, z, w);
  CAMLreturn(objc_wrap([CIVector vectorWithX:Double_val(x)
                                 Y:Double_val(y)
                                 Z:Double_val(z)
                                 W:Double_val(w)]));
}

