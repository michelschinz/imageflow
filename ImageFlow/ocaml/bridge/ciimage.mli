open Corefoundation
open Objc

external imageWithCGImage: [`CGImage] cftyperef -> [`CIImage] objc
    = "CIImage__imageWithCGImage"

external extent: [`CIImage] objc -> float array
    = "CIImage_extent"
