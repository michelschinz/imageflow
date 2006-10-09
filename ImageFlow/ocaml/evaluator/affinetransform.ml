type t = float array

let components_array t =
  t

let identity =
  [| 1.0; 0.0; 0.0; 1.0; 0.0; 0.0 |]

let scale fx fy =
  [| fx; 0.0; 0.0; fy; 0.0; 0.0 |]

let translation dx dy =
  [| 1.0; 0.0; 0.0; 1.0; dx; dy |]

let rotation a = 
  let c = cos a and s = sin a in
  [| c; s; -. s; c; 0. ; 0. |]

let invert [| a; b; c; d; tx; ty |] =
  let div = d *. a -. b *. c in
  [| d /. div;
     -. b /. div;
     -. c /. div;
     a /. div;
     (ty *. c -. d *.tx) /. div;
     (b *. tx -. ty *. a) /. div |]

let concat [| a1; b1; c1; d1; tx1; ty1 |] [| a2; b2; c2; d2; tx2; ty2 |] =
  [| a1 *. a2 +. b1 *. c2;
     a1 *. b2 +. b1 *. d2;
     c1 *. a2 +. d1 *. c2;
     c1 *. b2 +. d1 *. d2;
     tx1 *. a2 +. ty1 *. c2 +. tx2;
     tx1 *. b2 +. ty1 *. d2 +. ty2 |]

let transform_point [| a; b; c; d; tx; ty |] p =
  let x = Point.x p and y = Point.y p in
  Point.make (a *. x +. c *. y +. tx) (b *. x +. d *. y +. ty)
