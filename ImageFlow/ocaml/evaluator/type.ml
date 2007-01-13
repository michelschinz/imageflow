type t =
    TVar of int
  | TFun of (t array) * t
  | TArray of t
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
  | TFun (ts, t) ->
      let tsl = Array.to_list ts in
      "(" ^ (String.concat "," (List.map to_string tsl)) ^ ")=>" ^ (to_string t)
  | TArray t ->
      (to_string t) ^ "[]"
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

