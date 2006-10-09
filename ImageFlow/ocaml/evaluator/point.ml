type t = { pt_x: float; pt_y: float }

let make x y = { pt_x = x; pt_y = y }

let components { pt_x = x; pt_y = y } = (x, y)
let components_array { pt_x = x; pt_y = y } = [| x; y |]

let to_string p =
  let (x, y) = components p in
  Printf.sprintf "(%f,%f)" x y

let zero = make 0. 0.

let x = function { pt_x = x } -> x
let y = function { pt_y = y } -> y

let translate p dx dy =
  { pt_x = p.pt_x +. dx; pt_y = p.pt_y +. dy }

let scale p f =
  { pt_x = p.pt_x *. f; pt_y = p.pt_y *. f }
