let enable =
  try
    (Sys.getenv "OCAML_LOG") = "YES"
  with
    Not_found -> false

let if_enabled f =
  if enable then f else (fun _ -> ())

let string =
  if_enabled
      (fun s ->
        prerr_string s;
        flush stderr)
