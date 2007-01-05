type t =
    TVar of int
  | TFun of (t array) * t
  | TArray of t
  | TImage
  | TMask
  | TColor
  | TRect
  | TSize
  | TPoint
  | TString
  | TNum
  | TInt
  | TBool
  | TAction
  | TError

val print : t -> unit
val to_string : t -> string
