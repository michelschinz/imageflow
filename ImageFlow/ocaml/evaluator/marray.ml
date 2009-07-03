let for_all p a =
  let rec loop i = (i < 0) || (p a.(i) && loop (i - 1)) in
  loop ((Array.length a) - 1)

let exists p a =
  let rec loop i = (i >= 0) && (p a.(i) || loop (i - 1)) in
  loop ((Array.length a) - 1)

let index e a =
  let rec loop i =
    if i = Array.length a then
      raise Not_found
    else if a.(i) = e then
      i
    else
      loop (succ i)
  in loop 0

let is_prefix a1 a2 =
  let l1 = Array.length a1 and l2 = Array.length a2 in
  let rec loop i = (i = l1) || (a1.(i) = a2.(i) && loop (succ i)) in
  l1 <= l2 && loop 0
