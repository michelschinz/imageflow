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
        
(* DEBUG *)

let verbose_eval cache expr =
  print_endline("eval: " ^ (Printer.to_string expr));
  let res = eval cache expr in
  print_endline("   => " ^ (Printer.to_string res));
  res
