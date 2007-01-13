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
