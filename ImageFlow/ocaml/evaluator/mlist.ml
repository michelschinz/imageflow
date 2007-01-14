let rec remove_first e = function
    [] -> []
  | hd :: tl when hd = e -> tl
  | hd :: tl -> hd :: (remove_first e tl)

let rec union l1 l2 = match l1, l2 with
  l1, [] -> l1
| [], l2 -> l2
| h1 :: t1, l2 ->
    if List.mem h1 l2 then union t1 l2 else union t1 (h1 :: l2)

let rec concat_map f = function
    [] -> []
  | h :: t -> (f h) @ (concat_map f t)

let rec cartesian_product = function
    [] -> [[]]
  | l :: ls ->
      let pls = cartesian_product ls in
      concat_map (fun e -> List.map (fun ll -> e :: ll) pls) l

let rec drop n l =
  if n = 0 then
    l
  else match l with
    _ :: tl -> drop (pred n) tl
  | _ -> failwith "drop"

let rec take n l =
  if n = 0 then
    []
  else match l with
    hd :: tl -> hd :: (take (pred n) tl)
  | _ -> failwith "take"

let first = List.hd

let rec last = function
    l :: [] -> l
  | _ :: tl -> last tl
  | _ -> failwith "last"
