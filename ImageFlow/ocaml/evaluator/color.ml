(* TODO add color space *)

type t = { cr_r: float; cr_g: float; cr_b: float; cr_a: float }

let make r g b a =
  { cr_r = r; cr_g = g; cr_b = b; cr_a = a }

let red c = c.cr_r
let green c = c.cr_g
let blue c = c.cr_b
let alpha c = c.cr_a

let components c =
  (c.cr_r, c.cr_g, c.cr_b, c.cr_a)

let to_string c =
  let (r, g, b, a) = components c
  and pc v = int_of_float (100.0 *. v) in
  Printf.sprintf "(R=%d%%,G=%d%%,B=%d%%,A=%d%%)" (pc r) (pc g) (pc b) (pc a)

let transparent = { cr_r = 0.0; cr_g = 0.0; cr_b = 0.0; cr_a = 0.0 }

let cicolor c =
  let (r, g, b, a) = components c in
  Cicolor.colorWithRedGreenBlueAlpha r g b a
