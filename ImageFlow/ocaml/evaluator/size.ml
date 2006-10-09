type t = { se_width: float; se_height: float }

let make w h = { se_width = w; se_height = h }

let components { se_width = w; se_height = h } = (w, h)
let components_array { se_width = w; se_height = h } = [| w; h |]

let to_string s =
  let (w, h) = components s in
  Printf.sprintf "(%fx%f)" w h

let zero = make 0. 0.

let width = function { se_width = w } -> w
let height = function { se_height = h } -> h

let scale s f =
  { se_width = s.se_width *. f; se_height = s.se_height *. f }

let grow { se_width = w; se_height = h } dw dh =
  { se_width = w +. dw; se_height = h +. dh }
