#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include "corefoundation.h"

static void cf_finalize(value v) {
  const void* ptr = cf_unwrap(v);
  if (ptr != NULL)
    CFRelease(ptr);
}

static long cf_hash(value v) {
  CAMLparam1(v);
  CAMLreturn((long)CFHash(cf_unwrap(v)));
}

static struct custom_operations cf_custom_ops = {
  "com.imageflow.cf",
  cf_finalize,
  custom_compare_default,
  cf_hash,
  custom_serialize_default,
  custom_deserialize_default
};

value cf_wrap(CFTypeRef cf_value) {
  CAMLparam0();
  if (cf_value != NULL)
    CFRetain(cf_value);
  CAMLlocal1(block);
  block = caml_alloc_custom(&cf_custom_ops, sizeof(CFTypeRef), 0, 1);
  *((CFTypeRef*)Data_custom_val(block)) = cf_value;
  CAMLreturn(block);
}

value cf_is_null(value object) {
  return Val_bool(cf_unwrap(object) == NULL);
}
