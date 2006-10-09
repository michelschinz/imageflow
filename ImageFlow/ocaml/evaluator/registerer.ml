(* Register public functions for use from Objective-C *)

let _ =
  let register name f =
    print_string (" " ^ name);
    Callback.register name f in
  print_string "Registering OCaml callbacks:";
  register "Cache.make" Cache.make;
  register "Optevaluator.eval" Optevaluator.eval;
  register "Color.make" Color.make;
  register "Rect.make" Rect.make;
  register "Rect.components_array" Rect.components_array;
  register "Point.make" Point.make;
  register "Point.components_array" Point.components_array;
  register "Size.make" Size.make;
  register "Size.components_array" Size.components_array;
  register "Color.make" Color.make;
  register "Image.of_ifimage" Image.of_ifimage;
  register "Image.to_ifimage" Image.to_ifimage;
  print_endline ""
