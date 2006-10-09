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

let is_value = function
    Op _
  | Var _
  | Parent _ ->
      false
  | Array _
  | Image _
  | Mask _
  | Color _
  | Rect _
  | Size _
  | Point _
  | String _
  | Num _
  | Bool _
  | Action _
  | Error _ ->
      true

let is_error = function
    Error _ -> true
  | _ -> false

let rec equal e1 e2 =
  let equalArray a1 a2 =
    let rec loop i = (i < 0) || ((equal a1.(i)  a2.(i)) && (loop (i - 1))) in
    (Array.length a1) = (Array.length a2) && loop ((Array.length a1) - 1)
  in match (e1, e2) with
    (Op (n1, a1), Op (n2, a2)) ->
      (n1 = n2) && (equalArray a1 a2)
  | (Array a1, Array a2) ->
      equalArray a1 a2
  | (Var _, Var _)
  | (Parent _, Parent _)
  | (Color _, Color _)
  | (Rect _, Rect _)
  | (Size _, Size _)
  | (Point _, Point _)
  | (String _, String _)
  | (Num _, Num _)
  | (Bool _, Bool _)
  | (Error _, Error _) ->
      e1 = e2
  | (Image i1, Image i2)
  | (Mask i1, Mask i2) ->
      Nsobject.isEqual (Image.to_ifimage i1) (Image.to_ifimage i2)
  | (Action _, Action _) ->
      failwith "Expr.equal: cannot compare actions"
  | (_, _) ->
      false
