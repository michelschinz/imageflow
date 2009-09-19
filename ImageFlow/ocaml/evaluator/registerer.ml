(* Register public functions for use from Objective-C *)

open Callback

let _ =
  register "Cache.make" Cache.make;
  register "Typechecker.check" Typechecker.check;
  register "Typechecker.first_valid_configuration" Typechecker.first_valid_configuration;
  register "Optevaluator.eval" Optevaluator.eval;
  register "Optevaluator.eval_as_image" Optevaluator.eval_as_image;
  register "Optevaluator.eval_as_masked_image" Optevaluator.eval_as_masked_image;
  register "Delta.delta_array" Delta.delta_array;
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
