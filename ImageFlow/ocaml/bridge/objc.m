#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/custom.h>

#import <Foundation/Foundation.h>

#import "objc.h"

static void objc_finalize(value v) {
  [objc_unwrap(v) release];
}

static long objc_hash(value v) {
  return [objc_unwrap(v) hash];
}

static int objc_compare(value v1, value v2) {
  NSObject* o1 = objc_unwrap(v1);
  NSObject* o2 = objc_unwrap(v2);
  if (o1 == o2 || [o1 isEqual:o2])
    return 0;
  else if (o1 < o2)
    return -1;
  else
    return 1;
}

static struct custom_operations objc_custom_ops = {
  "com.imageflow.objc",
  objc_finalize,
  objc_compare,
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
