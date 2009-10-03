type t =
    TVar of int
  | TFun of t * t
  | TArray of t
  | TTuple of t list
  | TImage of t
  | TColor_RGBA
  | TRect
  | TSize
  | TPoint
  | TString
  | TFloat
  | TInt
  | TBool
  | TAction
  | TError

val print : t -> unit
val to_string : t -> string
