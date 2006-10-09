#include <assert.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include <ApplicationServices/ApplicationServices.h>

#include "corefoundation.h"

CAMLprim value _CGImageGetWidth(value wrapped_cgimage) {
  CGImageRef cgimage = (CGImageRef)cf_unwrap(wrapped_cgimage);
  return caml_copy_double(CGImageGetWidth(cgimage));
}

CAMLprim value _CGImageGetHeight(value wrapped_cgimage) {
  CGImageRef cgimage = (CGImageRef)cf_unwrap(wrapped_cgimage);
  return caml_copy_double(CGImageGetHeight(cgimage));
}
