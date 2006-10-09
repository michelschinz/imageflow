let rec remove_first e = function
    [] -> []
  | hd :: tl when hd = e -> tl
  | hd :: tl -> hd :: (remove_first e tl)
