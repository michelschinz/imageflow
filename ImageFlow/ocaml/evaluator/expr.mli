(* Warning: any change to the type below must be mirrored in file *)
(* ../../IFExpressionTags.h *)

type action_kind = ASave | APrint

type t =
    (* "real" expressions (non-values) *)
  | Lambda of t
  | Map of t * t
  | Apply of t * t
  | Prim of Primitives.t * t array
  | Var of string
  | Arg of int
    (* values *)
  | Closure of (t list) * t
  | Array of t array
  | Image of Image.t
  | Mask of Image.t
  | Color of Color.t
  | Rect of Rect.t
  | Size of Size.t
  | Point of Point.t
  | String of string
  | Num of float
  | Int of int
  | Bool of bool
  | Action of action_kind * (t -> unit)
  | Error of string option

val is_value: t -> bool
val is_error: t -> bool

val is_image: t -> bool
val is_mask: t -> bool

val equal: t -> t -> bool
