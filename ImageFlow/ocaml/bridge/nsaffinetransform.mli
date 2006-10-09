open Objc

external transform: unit -> [`NSAffineTransform] objc
    = "NSAffineTransform__transform"

external setTransformStruct: [`NSAffineTransform] objc -> float array -> unit
    = "NSAffineTransform_setTransformStruct"
