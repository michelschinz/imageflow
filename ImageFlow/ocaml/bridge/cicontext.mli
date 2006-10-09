open Corefoundation
open Objc

external contextWithCGContextOptions:
  [`CGContext] cftyperef -> [`NSDictionary] objc -> [`CIContext] objc
      = "CIContext__contextWithCGContextOptions"

external createCGImageFromRect: [`CIContext] objc -> (float * float * float * float) -> [`CGImage] cftyperef
    = "CIContext_createCGImageFromRect"
