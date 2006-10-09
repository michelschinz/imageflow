(* Warning: any change to the type below must be mirrored in file *)
(* ../../IFExpressionTags.h *)

type t =
    Op of string * t array
  | Var of string
  | Parent of int
  | Array of t array
  | Image of Image.t
  | Mask of Image.t
  | Color of Color.t
  | Rect of Rect.t
  | Size of Size.t
  | Point of Point.t
  | String of string
  | Num of float
  | Bool of bool
  | Action of string * (t -> unit)
  | Error of string option

val is_value: t -> bool
val is_error: t -> bool

val equal: t -> t -> bool
