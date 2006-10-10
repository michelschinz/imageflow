#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "objc.h"

CAMLprim value CIColor__colorWithRedGreenBlueAlpha(value r, value g, value b, value a) {
  CAMLparam4(r, g, b, a);
  CAMLreturn(objc_wrap([CIColor colorWithRed:Double_val(r) green:Double_val(g) blue:Double_val(b) alpha:Double_val(a)]));
}
