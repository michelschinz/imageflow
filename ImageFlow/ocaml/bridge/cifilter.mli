open Objc

external filterWithName: [`NSString] objc -> [`CIFilter] objc
    = "CIFilter__filterWithName"

external setColor: filter:[`CIFilter] objc -> color:[`CIColor] objc -> key:[`NSString] objc -> unit
    = "CIFilter_setValueForKey"

external setImage: filter:[`CIFilter] objc -> image:[`CIImage] objc -> key:[`NSString] objc -> unit
    = "CIFilter_setValueForKey"

external setNumber: filter:[`CIFilter] objc -> number:[`NSNumber] objc -> key:[`NSString] objc -> unit
    = "CIFilter_setValueForKey"

external setVector: filter:[`CIFilter] objc -> vector:[`CIVector] objc -> key:[`NSString] objc -> unit
    = "CIFilter_setValueForKey"

external setString: filter:[`CIFilter] objc -> string:[`NSString] objc -> key:[`NSString] objc -> unit
    = "CIFilter_setValueForKey"

external setTransform: filter:[`CIFilter] objc -> transform:[`NSAffineTransform] objc -> key:[`NSString] objc -> unit
    = "CIFilter_setValueForKey"

external imageForKey:[`CIFilter] objc -> [`NSString] objc -> [`CIImage] objc
    = "CIFilter_valueForKey"
