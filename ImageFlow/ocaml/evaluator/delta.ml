open Expr
open Primitives

(* TODO: add lambda, map, var *)
let rec delta cache old_expr new_expr =
  let extent expr =
    match Optevaluator.eval_extent cache expr with
      Some r -> r
    | None -> Rect.zero
  in
  if new_expr = old_expr then
    Rect.zero
  else match old_expr, new_expr with
    b1, Prim(PBlend,[|b2;f;_|]) when b1 = b2 ->
      extent f
  | Prim(PPaint, [|b1;Array ps1|]), Prim(PPaint, [|b2;Array ps2|])
    when b1 = b2 && Marray.is_prefix ps1 ps2 ->
      let l1 = Array.length ps1 and l2 = Array.length ps2 in
      let new_ps = Array.sub ps2 (l1 - 1) (l2 - l1 + 1) in
      extent (Prim(PPaint, [|b1; Array new_ps|]))
  | Prim(PCropOverlay, [|i1;Rect r1|]), Prim(PCropOverlay, [|i2;Rect r2|])
    when i1 = i2 ->
      Rect.union r1 r2

        (* Recursing rules*)
  | Prim(PBlend,[|b1;f1;m1|]), Prim(PBlend,[|b2;f2;m2|]) when f1 = f2 && m1 = m2->
      delta cache b1 b2
  | Prim(PBlend,[|b1;f1;m1|]), Prim(PBlend,[|b2;f2;m2|]) when b1 = b2 && m1 = m2->
      delta cache f1 f2
  | Prim(PChannelToMask, [|i1;c1|]), Prim(PChannelToMask, [|i2;c2|])
    when c1 = c2 ->
      delta cache i1 i2
  | Prim(PCrop, [|i1;Rect r1|]), Prim(PCrop, [|i2; Rect r2|]) when r1 = r2 ->
      Rect.intersection r1 (delta cache i1 i2)
  | Prim(PGaussianBlur, [|i1;Num r1|]), Prim(PGaussianBlur, [|i2; Num r2|])
    when r1 = r2 ->
      Rect.outset (delta cache i1 i2) r1 r1
  | Prim(PInvert,[|i1|]), Prim(PInvert,[|i2|]) ->
      delta cache i1 i2
  | Prim(PInvertMask,[|i1|]), Prim(PInvertMask,[|i2|]) ->
      delta cache i1 i2
  | Prim(PMask,[|i1;m1|]), Prim(PMask,[|i2;m2|]) when i1 = i2 ->
      delta cache m1 m2
  | Prim(PMask,[|i1;m1|]), Prim(PMask,[|i2;m2|]) when m1 = m2 ->
      delta cache i1 i2
  | Prim(PMaskOverlay,[|i1;m1;c1|]), Prim(PMaskOverlay,[|i2;m2;c2|])
    when i1 = i2 && c1 = c2 ->
      delta cache m1 m2
  | Prim(PMaskOverlay,[|i1;m1;c1|]), Prim(PMaskOverlay,[|i2;m2;c2|])
    when m1 = m2 && c1 = c2 ->
      delta cache i1 i2
  | Prim(POpacity,[|i1;a1|]), Prim(POpacity,[|i2;a2|]) when a1 = a2 ->
      delta cache i1 i2
  | Prim(PResample,[|i1;Num f1|]), Prim(PResample,[|i2;Num f2|]) when f1 = f2 ->
      delta cache i1 i2
  | Prim(PSingleColor,[|i1;Color c1|]), Prim(PSingleColor,[|i2;Color c2|])
    when c1 = c2 ->
      delta cache i1 i2
  | Prim(PThreshold,[|i1;Num t1|]), Prim(PThreshold,[|i2;Num t2|]) when t1 = t2 ->
      delta cache i1 i2
  | Prim(PThresholdMask,[|i1;Num t1|]), Prim(PThresholdMask,[|i2;Num t2|]) when t1 = t2 ->
      delta cache i1 i2
  | Prim(PTranslate,[|i1;p1|]), Prim(PTranslate,[|i2;p2|]) when p1 = p2 ->
      delta cache i1 i2
  | Prim(PUnsharpMask,[|i1;Num y1; Num r1|]), Prim(PUnsharpMask,[|i2;Num y2; Num r2|])
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
