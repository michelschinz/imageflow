(* Warning: any change to the type below must be mirrored in file *)
(* ../../IFBlendMode.h *)

type t =
    SourceOver
  | Color
  | ColorBurn
  | ColorDodge
  | Darken
  | Difference
  | Exclusion
  | HardLight
  | Hue
  | Lighten
  | Luminosity
  | Multiply
  | Overlay
  | Saturation
  | Screen
  | SoftLight

val of_int : int -> t
val to_int : t -> int
val to_coreimage : t -> string
