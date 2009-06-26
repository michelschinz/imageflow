open Objc

external array: unit -> [`NSMutableArray] objc
    = "NSMutableArray__array"

external addImage: array:[`NSMutableArray] objc -> image:[`CIImage] objc -> unit
    = "NSMutableArray_addObject"
