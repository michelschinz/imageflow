#import <caml/mlvalues.h>
#import <caml/memory.h>

#import <Foundation/Foundation.h>

#import "objc.h"

CAMLprim value CIContext__contextWithCGContextOptions(value cgcontext,
                                                      value options) {
  CAMLparam2(cgcontext, options);
  CAMLreturn(objc_wrap([CIContext contextWithCGContext:cf_unwrap(cgcontext)
                                  options:objc_unwrap(options)]));
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
    cf_wrap([objc_unwrap(self) createCGImage:objc_unwrap(image)
                        fromRect:cgRect]);
  CGImageRelease(cf_unwrap(wrapped_image));
  CAMLreturn(wrapped_image);
}

