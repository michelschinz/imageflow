type action_kind = ASave | APrint

type t =
    (* "real" expressions (non-values) *)
  | Lambda of t
  | Map of t * t
  | Apply of t * t
  | Prim of Primitives.t * t array
  | Arg of int
    (* values *)
  | Closure of (t list) * t
  | Array of t array
  | Tuple of t array
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

let is_value = function
  | Lambda _
  | Map _
  | Apply _
  | Prim _
  | Arg _ ->
      false
  | Closure _
  | Array _
  | Tuple _
  | Image _
  | Mask _
  | Color _
  | Rect _
  | Size _
  | Point _
  | String _
  | Num _
  | Int _
  | Bool _
  | Action _
  | Error _ ->
      true

let is_error = function
    Error _ -> true
  | _ -> false

let is_image = function
    Image _ -> true
  | _ -> false

let is_mask = function
    Mask _ -> true
  | _ -> false

let rec equal (e1 : t) (e2 : t) =
  let equalArray a1 a2 =
    let rec loop i = (i < 0) || ((equal a1.(i)  a2.(i)) && (loop (i - 1))) in
    (Array.length a1) = (Array.length a2) && loop ((Array.length a1) - 1)
  in match e1, e2 with
    Prim (p1, a1), Prim (p2, a2) ->
      p1 = p2 && (equalArray a1 a2)
  | Array a1, Array a2
  | Tuple a1, Tuple a2 ->
      equalArray a1 a2
  | Lambda _, Lambda _
  | Map _, Map _
  | Apply _, Apply _
  | Arg _, Arg _
  | Closure _, Closure _
  | Color _, Color _
  | Rect _, Rect _
  | Size _, Size _
  | Point _, Point _
  | String _, String _
  | Num _, Num _
  | Int _, Int _
  | Bool _, Bool _
  | Error _, Error _ ->
      e1 = e2
  | Image i1, Image i2
  | Mask i1, Mask i2 ->
      Nsobject.isEqual (Image.to_ifimage i1) (Image.to_ifimage i2)
  | Action _, Action _ ->
      failwith "Expr.equal: cannot compare actions"
  | _, _ ->
      false
