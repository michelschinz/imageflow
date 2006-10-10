#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/custom.h>

#import <Foundation/Foundation.h>

#import "objc.h"

static void objc_finalize(value v) {
  [objc_unwrap(v) release];
}

static long objc_hash(value v) {
  CAMLparam1(v);
  CAMLreturn(Val_int([objc_unwrap(v) hash]));
}

static struct custom_operations objc_custom_ops = {
  "com.imageflow.objc",
  objc_finalize,
  custom_compare_default,
  objc_hash,
  custom_serialize_default,
  custom_deserialize_default
};

value objc_really_wrap(id objc_object, BOOL retainFirst) {
  value block = caml_alloc_custom(&objc_custom_ops, sizeof(void*), 0, 1);
  *((id*)Data_custom_val(block)) =
    retainFirst ? [objc_object retain] : objc_object;
  return block;
}

value objc_wrap(id objc_object) {
  return objc_really_wrap(objc_object, YES);
}

value objc_wrap_no_retain(id objc_object) {
  return objc_really_wrap(objc_object, NO);
}
