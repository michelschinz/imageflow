type t = float * float

let make b e = (b, e)

let min (b, _) = b
let max (_, e) = e
let length (b, e) = e -. b

let intersects (b1, e1) (b2, e2) =
  (b2 <= b1 && b1 <= e2) || (b1 <= b2 && b2 <= e1)

let intersection i1 i2 =
  if intersects i1 i2 then
    let (b1, e1) = i1 and (b2, e2) = i2 in
    Some (Pervasives.max b1 b2, Pervasives.min e1 e2)
  else
    None
