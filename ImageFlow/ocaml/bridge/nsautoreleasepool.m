#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>

#import "objc.h"

CAMLprim value NSAutoreleasePool__new() {
  return objc_wrap_no_retain([NSAutoreleasePool new]);
}
