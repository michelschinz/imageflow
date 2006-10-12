open Expr

let rec delta cache old_expr new_expr =
  let extent expr =
    match Optevaluator.eval_extent cache expr with
      Some r -> r
    | None -> Rect.zero
  in
  if new_expr = old_expr then
    Rect.zero
  else match old_expr, new_expr with
    b1, Op("blend",[|b2;f;_|]) when b1 = b2 ->
      extent f
  | Op("blend",[|b1;f1;m1|]), Op("blend",[|b2;f2;m2|]) when b1 = b2 && m1 = m2->
      delta cache f1 f2
  | Op("crop", [|i1;Rect r1|]), Op("crop", [|i2; Rect r2|]) when r1 = r2 ->
      Rect.intersection r1 (delta cache i1 i2)
  | _, _ ->
      Rect.union (extent old_expr) (extent new_expr)

let delta_array cache old_expr new_expr =
  Rect.components_array (delta cache old_expr new_expr)

let verbose_delta_array cache old_expr new_expr =
  let r = (delta cache old_expr new_expr) in
  print_endline ("old: "^(Printer.to_string old_expr));
  print_endline ("new: "^(Printer.to_string new_expr));
  print_endline ("delta: "^(Rect.to_string r));
  Rect.components_array r
