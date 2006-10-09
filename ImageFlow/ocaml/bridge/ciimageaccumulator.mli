open Corefoundation
open Objc

external imageAccumulatorWithExtent: float array -> [`CIImageAccumulator] objc
    = "CIImageAccumulator__imageAccumulatorWithExtent"

external extent: [`CIImageAccumulator] objc -> float array
    = "CIImageAccumulator_extent"

external setImage: [`CIImageAccumulator] objc -> [`CIImage] objc -> unit
    = "CIImageAccumulator_setImage"

external image: [`CIImageAccumulator] objc -> [`CIImage] objc
    = "CIImageAccumulator_image"
