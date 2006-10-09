#include <objc/objc.h>
#include <objc/objc-runtime.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>

#include "objc.h"

static id CIContextClass = NULL;

CAMLprim value CIContext__contextWithCGContextOptions(value cgcontext,
                                                      value options) {
  CAMLparam2(cgcontext, options);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("contextWithCGContext:options:");
  if (CIContextClass == NULL)
    CIContextClass = objc_getClass("CIContext");
  CAMLreturn(objc_wrap(objc_msgSend(CIContextClass,
                                    sel,
                                    cf_unwrap(cgcontext),
                                    objc_unwrap(options))));
}

CAMLprim value CIContext_createCGImageFromRect(value self,
                                               value image,
                                               value rect) {
  CAMLparam3(self, image, rect);
  static SEL sel = NULL;
  if (sel == NULL)
    sel = sel_registerName("createCGImage:fromRect:");
  CGRect cgRect = CGRectMake(Double_field(rect, 0),
                             Double_field(rect, 1),
                             Double_field(rect, 2),
                             Double_field(rect, 3));
  value wrapped_image =
    cf_wrap(objc_msgSend(objc_unwrap(self), sel, objc_unwrap(image), cgRect));
  CGImageRelease(cf_unwrap(wrapped_image));
  CAMLreturn(wrapped_image);
}

