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

let rec to_string = function
    TVar i ->
      Printf.sprintf "'t%d" i
  | TFun (ts, t) ->
      let tsl = Array.to_list ts in
      "(" ^ (String.concat "," (List.map to_string tsl)) ^ ")=>" ^ (to_string t)
  | TArray t ->
      (to_string t) ^ "[]"
  | TImage ->
      "Image"
  | TMask ->
      "Mask"
  | TColor ->
      "Color"
  | TRect ->
      "Rect"
  | TSize ->
      "Size"
  | TPoint ->
      "Point"
  | TString ->
      "String"
  | TNum ->
      "Num"
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

