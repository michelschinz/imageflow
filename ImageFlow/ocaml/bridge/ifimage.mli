open Objc
open Corefoundation

external imageWithCGImage: [ `CGImage ] cftyperef -> [ `IFImage ] objc
    = "IFImage__imageWithCGImage"

external imageWithCIImage: [ `CIImage ] objc -> [ `IFImage ] objc
    = "IFImage__imageWithCIImage"

external extent: [ `IFImage ] objc -> float array
    = "IFImage_extent"

external imageCI: [ `IFImage ] objc -> [ `CIImage ] objc
    = "IFImage_imageCI"

external isLocked: [ `IFImage ] objc -> bool
    = "IFImage_isLocked"

external logRetainCounts: [ `IFImage ] objc -> unit
    = "IFImage_logRetainCounts"
