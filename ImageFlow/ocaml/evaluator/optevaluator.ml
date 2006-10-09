open Expr

(* Add cacheing to an evaluation function *)
let cacheingEval cache eval expr =
  try
    Cache.lookup cache expr
  with Not_found ->
    let res = eval expr in
    begin match res with
      Image res_image when not (is_value expr) ->
        Cache.store cache expr res_image
    | _ -> ()
    end;
    res

(* Add error propagation to an evaluation function *)
let propagatingEval eval = function
    Op(_, args) when Marray.exists is_error args ->
      Error None
  | Array elems when Marray.exists is_error elems ->
      Error None
  | Error _ ->
      Error None
  | expr ->
      eval expr

(* Turn a single-level evaluation function to a recursive one *)
let rec recursingEval eval = function
    Op(op, args) ->
      eval (Op(op, Array.map (recursingEval eval) args))
  | Array elems ->
      eval (Array (Array.map (recursingEval eval) elems))
  | other when not (is_value other) ->
      eval other
  | value ->
      value

(* Add logging to an evaluation function *)
let loggingEval eval expr =
  print_endline (" eval: " ^ (Printer.to_string expr));
  let res = eval expr in
  print_endline ("    => " ^ (Printer.to_string res));
  res

let (++) f g x = f (g x)

let eval cache expr =
  (recursingEval ++ (cacheingEval cache) ++ propagatingEval) Evaluator.eval
    (Optimiser.rewrite expr)
