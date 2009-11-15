open Objc
open Corefoundation

external emptyImage: unit -> [ `IFImage ] objc
    = "IFImage__emptyImage"

external imageWithCGImage: [ `CGImage ] cftyperef -> [ `IFImage ] objc
    = "IFImage__imageWithCGImage"

external imageWithCIImage: [ `CIImage ] objc -> [ `IFImage ] objc
    = "IFImage__imageWithCIImage"

external maskWithCIImage: [ `CIImage ] objc -> [ `IFImage ] objc
    = "IFImage__maskWithCIImage"

external extent: [ `IFImage ] objc -> float array
    = "IFImage_extent"

external imageCI: [ `IFImage ] objc -> [ `CIImage ] objc
    = "IFImage_imageCI"

external isLocked: [ `IFImage ] objc -> bool
    = "IFImage_isLocked"

