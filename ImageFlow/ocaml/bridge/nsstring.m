#import <Foundation/Foundation.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/alloc.h>

#import "objc.h"

CAMLprim value NSString__stringWithUTF8String(value string) {
  CAMLparam1(string);
  CAMLreturn(objc_wrap([NSString stringWithUTF8String:String_val(string)]));
}

CAMLprim value NSString_UTF8String(value self) {
  CAMLparam1(self);
  CAMLreturn(caml_copy_string((char*)[objc_unwrap(self) UTF8String]));
}
