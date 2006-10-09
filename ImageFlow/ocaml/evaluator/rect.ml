type t = { re_origin: Point.t; re_size: Size.t }

let make x y w h = { re_origin = Point.make x y; re_size = Size.make w h }

let zero = { re_origin = Point.zero; re_size = Size.zero }
let infinite = { re_origin = Point.make min_float min_float;
                 re_size = Size.make max_float max_float }

let x_min r = Point.x r.re_origin
let x_max r = (Point.x r.re_origin) +. (Size.width r.re_size)
let y_min r = Point.y r.re_origin
let y_max r = (Point.y r.re_origin) +. (Size.height r.re_size)

let width r = Size.width r.re_size
let height r = Size.height r.re_size

let components r = (x_min r, y_min r, width r, height r)
let components_array r = [| x_min r; y_min r; width r; height r |]

let to_string r =
  let (x, y, w, h) = components r in
  Printf.sprintf "[X=%f,Y=%f,W=%f,H=%f]" x y w h

let translate r dx dy =
  { r with re_origin = (Point.translate r.re_origin dx dy) }

let scale r f =
  { re_origin = Point.scale r.re_origin f; re_size = Size.scale r.re_size f }

let outset r dx dy =
  { re_origin = Point.translate r.re_origin (-. dx) (-. dy);
    re_size = Size.grow r.re_size (2. *. dx) (2. *. dy) }

let inset r dx dy = outset r (-. dx) (-. dy)

let union r1 r2 =
  let x_min = min (x_min r1) (x_min r2)
  and y_min = min (y_min r1) (y_min r2) in
  let x_max = max (x_max r1) (x_max r2)
  and y_max = max (y_max r1) (y_max r2) in
  { re_origin = Point.make x_min y_min;
    re_size = Size.make (x_max -. x_min) (y_max -. y_min) }

module Ival = Interval

let proj_x r = Ival.make (x_min r) (x_max r)
let proj_y r = Ival.make (y_min r) (y_max r)

let intersects r1 r2 =
  (Ival.intersects (proj_x r1) (proj_x r2))
    && (Ival.intersects (proj_y r1) (proj_y r2))

let intersection r1 r2 =
  match (Ival.intersection (proj_x r1) (proj_x r2),
         Ival.intersection (proj_y r1) (proj_y r2)) with
    (Some ix, Some iy) ->
      make (Ival.min ix) (Ival.min iy) (Ival.length ix) (Ival.length iy)
  | _ -> zero
