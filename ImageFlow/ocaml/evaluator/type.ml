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

let rec to_string = function
    TVar i ->
      Printf.sprintf "'t%d" i
  | TFun (ta, tr) ->
      (to_string ta) ^ "=>" ^ (to_string tr)
  | TArray t ->
      "Array[" ^ (to_string t) ^ "]"
  | TTuple ts ->
      "(" ^ (String.concat "," (List.map to_string ts)) ^ ")"
  | TImage t ->
      "Image[" ^ (to_string t) ^ "]"
  | TColor_RGBA ->
      "Color_RGBA"
  | TRect ->
      "Rect"
  | TSize ->
      "Size"
  | TPoint ->
      "Point"
  | TString ->
      "String"
  | TFloat ->
      "Float"
  | TInt ->
      "Int"
  | TBool ->
      "Bool"
  | TAction ->
      "Action"
  | TError ->
      "Error"

let print t =
  print_string (to_string t)

