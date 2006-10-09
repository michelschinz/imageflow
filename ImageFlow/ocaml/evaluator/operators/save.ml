open Objc

external cg_save: [`CIImage] objc -> string -> string -> unit
    = "cg_save"

let exec_save =
  cg_save
