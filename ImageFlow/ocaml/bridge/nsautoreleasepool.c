#include <assert.h>
#include <objc/objc.h>
#include <objc/objc-runtime.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

static id NSAutoreleasePoolClass = NULL;

CAMLprim value NSAutoreleasePool__new() {
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("new");
  if (NSAutoreleasePoolClass == NULL) {
    NSAutoreleasePoolClass = objc_getClass("NSAutoreleasePool");
    assert(NSAutoreleasePoolClass != NULL);
  }
  return objc_wrap_no_retain(objc_msgSend(NSAutoreleasePoolClass, sel));
}
