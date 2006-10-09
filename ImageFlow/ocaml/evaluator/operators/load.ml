open Corefoundation

external cg_load: string -> [`CGImage] cftyperef
    = "cg_load"

let eval_load file_name =
  let cg_image = cg_load file_name in
  if is_null cg_image then
    failwith "File not found"
  else
    cg_image
