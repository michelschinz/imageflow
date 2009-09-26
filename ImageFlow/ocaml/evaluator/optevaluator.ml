open Expr
open Primitives

let eval cache expr =
  try
    Evaluator.eval cache [] (Optimiser.rewrite expr)
  with
    Evaluator.EvalError e ->
      e

let eval_extent cache expr =
  match eval cache (Prim(Extent, [|expr|])) with
    Rect extent ->
      Some extent
  | Error _ ->
      None
  | o ->
      failwith ("unexpected result from evaluator: "^(Printer.to_string(o)))

let eval_as_image =
  let background = Prim(Checkerboard, [| Point Point.zero;
                                         Color (Color.make 1. 1. 1. 1.);
                                         Color (Color.make 0.8 0.8 0.8 1.);
                                         Num 40.0;
                                         Num 1.0 |])
  in fun cache expr ->
    match eval cache expr with
      Mask _ as mask ->
        eval cache (Prim(MaskToImage, [| mask |]))
    | Image _ as image ->
        eval
          cache
          (Prim(Blend, [| background;
                          image;
                          Int (Blendmode.to_int Blendmode.SourceOver) |]))
    | Error _ as error ->
        error
    | other ->
        failwith ("non-image result from evaluator: "
                  ^ (Printer.to_string(other)))

let eval_as_masked_image =
  let mask_cutout_margin = 20.0
  and mask_color = Color.make 0.5 0.5 0.5 1.0
  in fun cache expr mask_cutout_bounds ->
    match eval_as_image cache expr with
      Image _ as image ->
        eval
          cache
          (Prim(RectangularWindow,
              [| image;
                 Color mask_color;
                 Rect mask_cutout_bounds;
                 Num mask_cutout_margin |]))
    | Error _ as error ->
        error
    | other ->
        failwith ("non-image result from evaluator: "
                  ^ (Printer.to_string(other)))
        
(* DEBUG *)

let verbose_eval cache expr =
  print_endline("eval: " ^ (Printer.to_string expr));
  let res = eval cache expr in
  print_endline("   => " ^ (Printer.to_string res));
  res
