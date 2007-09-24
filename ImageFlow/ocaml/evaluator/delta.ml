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
  | Op("paint", [|b1;Array ps1|]), Op("paint", [|b2;Array ps2|])
    when b1 = b2 && Marray.is_prefix ps1 ps2 ->
      let l1 = Array.length ps1 and l2 = Array.length ps2 in
      let new_ps = Array.sub ps2 (l1 - 1) (l2 - l1 + 1) in
      extent (Op("paint", [|b1; Array new_ps|]))
  | Op("crop-overlay", [|i1;Rect r1|]), Op("crop-overlay", [|i2;Rect r2|])
    when i1 = i2 ->
      Rect.union r1 r2

        (* Recursing rules*)
  | Op("blend",[|b1;f1;m1|]), Op("blend",[|b2;f2;m2|]) when f1 = f2 && m1 = m2->
      delta cache b1 b2
  | Op("blend",[|b1;f1;m1|]), Op("blend",[|b2;f2;m2|]) when b1 = b2 && m1 = m2->
      delta cache f1 f2
  | Op("channel-to-mask", [|i1;c1|]), Op("channel-to-mask", [|i2;c2|])
    when c1 = c2 ->
      delta cache i1 i2
  | Op("crop", [|i1;Rect r1|]), Op("crop", [|i2; Rect r2|]) when r1 = r2 ->
      Rect.intersection r1 (delta cache i1 i2)
  | Op("gaussian-blur", [|i1;Num r1|]), Op("gaussian-blur", [|i2; Num r2|])
    when r1 = r2 ->
      Rect.outset (delta cache i1 i2) r1 r1
  | Op("invert",[|i1|]), Op("invert",[|i2|]) ->
      delta cache i1 i2
  | Op("invert-mask",[|i1|]), Op("invert-mask",[|i2|]) ->
      delta cache i1 i2
  | Op("mask",[|i1;m1|]), Op("mask",[|i2;m2|]) when i1 = i2 ->
      delta cache m1 m2
  | Op("mask",[|i1;m1|]), Op("mask",[|i2;m2|]) when m1 = m2 ->
      delta cache i1 i2
  | Op("mask-overlay",[|i1;m1;c1|]), Op("mask-overlay",[|i2;m2;c2|])
    when i1 = i2 && c1 = c2 ->
      delta cache m1 m2
  | Op("mask-overlay",[|i1;m1;c1|]), Op("mask-overlay",[|i2;m2;c2|])
    when m1 = m2 && c1 = c2 ->
      delta cache i1 i2
  | Op("opacity",[|i1;a1|]), Op("opacity",[|i2;a2|]) when a1 = a2 ->
      delta cache i1 i2
  | Op("resample",[|i1;Num f1|]), Op("resample",[|i2;Num f2|]) when f1 = f2 ->
      delta cache i1 i2
  | Op("single-color",[|i1;Color c1|]), Op("single-color",[|i2;Color c2|])
    when c1 = c2 ->
      delta cache i1 i2
  | Op("threshold",[|i1;Num t1|]), Op("threshold",[|i2;Num t2|]) when t1 = t2 ->
      delta cache i1 i2
  | Op("threshold-mask",[|i1;Num t1|]), Op("threshold-mask",[|i2;Num t2|]) when t1 = t2 ->
      delta cache i1 i2
  | Op("translate",[|i1;p1|]), Op("translate",[|i2;p2|]) when p1 = p2 ->
      delta cache i1 i2
  | Op("unsharp-mask",[|i1;Num y1; Num r1|]), Op("unsharp-mask",[|i2;Num y2; Num r2|])
    when y1 = y2 && r1 = r2 ->
      delta cache i1 i2
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
