let exists p a =
  let rec loop i = (i >= 0) && (p a.(i) || loop (i - 1)) in
  loop ((Array.length a) - 1)
