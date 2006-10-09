#include <objc/objc.h>
#include <objc/objc-runtime.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include "objc.h"

static void objc_finalize(value v) {
  static SEL release = NULL;
  if (release == NULL)
    release = sel_registerName("release");
  objc_msgSend(objc_unwrap(v), release);
}

static long objc_hash(value v) {
  CAMLparam1(v);
  static SEL hash = NULL;
  if (hash == NULL)
    hash = sel_registerName("hash");
  CAMLreturn((long)objc_msgSend(objc_unwrap(v), hash));
}

static struct custom_operations objc_custom_ops = {
  "com.imageflow.objc",
  objc_finalize,
  custom_compare_default,
  objc_hash,
  custom_serialize_default,
  custom_deserialize_default
};

value objc_really_wrap(void* objc_object, int retainFirst) {
  static SEL retain = NULL;
  if (retain == NULL)
    retain = sel_registerName("retain");
  if (retainFirst)
    objc_msgSend(objc_object, retain);
  value block = caml_alloc_custom(&objc_custom_ops, sizeof(void*), 0, 1);
  *((void**)Data_custom_val(block)) = objc_object;
  return block;
}

value objc_wrap(void* objc_object) {
  return objc_really_wrap(objc_object, 1);
}

value objc_wrap_no_retain(void* objc_object) {
  return objc_really_wrap(objc_object, 0);
}
