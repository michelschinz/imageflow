open Expr
open Primitives

(* Optimisation by rewriting *)

let rec rewritePrim = function
  | Prim(PArrayGet, [| Prim(PArrayCreate, a); Int i |]) ->
      a.(i)
  | Prim(PTupleGet, [| Prim(PTupleCreate, a); Int i |]) ->
      a.(i)

    (* Commutation with resampling *)
  | Prim(PResample, [|Prim(PBlend, [|i1; i2; m|]); Num f|]) when f < 1. ->
      Prim(PBlend, [|Prim(PResample, [|i1; Num f|]);
                     Prim(PResample, [|i2; Num f|]); m|])
  | Prim(PResample, [|Prim(PChannelToMask, [|i; c|]); Num f|]) ->
      Prim(PChannelToMask, [|Prim(PResample, [|i; Num f|]); c|])
  | Prim(PResample,
         [|Prim(PCheckerboard, [|Point c; c1; c2; Num w; s|]); Num f|]) ->
           Prim(PCheckerboard,
                [|Point (Point.scale c f); c1; c2; Num (w *. f); s|])
  | Prim(PResample, [|Prim(PCircle, [|Point c; Num r; o|]); Num f|])
    when f < 1. ->
      Prim(PCircle, [|Point (Point.scale c f); Num (r *. f); o|])
  | Prim(PResample, [|Prim(PColorControls, [|i; c; b; s|]); Num f|])
    when f < 1. ->
      Prim(PColorControls, [|Prim(PResample, [|i; Num f|]); c; b; s|])
  | Prim(PResample, [|Prim(PCrop, [|i; Rect r|]); Num f|]) when f < 1. ->
      Prim(PCrop, [|Prim(PResample, [|i; Num f|]); Rect (Rect.scale r f)|])
  | Prim(PResample, [|Prim(PCropOverlay, [|i; Rect r|]); Num f|]) when f < 1. ->
      Prim(PCropOverlay,
           [|Prim(PResample, [|i; Num f|]); Rect (Rect.scale r f)|])
  | Prim(PResample, [|Prim(PGaussianBlur, [|i; Num r|]); Num f|]) when f < 1. ->
      Prim(PGaussianBlur, [|Prim(PResample, [|i; Num f|]); Num (r *. f)|])
  | Prim(PResample, [|Prim(PInvert, [|i|]); Num f|]) when f < 1. ->
      Prim(PInvert, [|Prim(PResample, [|i; Num f|])|])
  | Prim(PResample, [|Prim(PInvertMask, [|i|]); Num f|]) when f < 1. ->
      Prim(PInvertMask, [|Prim(PResample, [|i; Num f|])|])
  | Prim(PResample, [|Prim(PMask, [|i; m|]); Num f|]) when f < 1. ->
      Prim(PMask, [|Prim(PResample, [|i; Num f|]); Prim(PResample, [|m; Num f|])|])
  | Prim(PResample, [|Prim(PMaskOverlay, [|i; m; c|]); Num f|]) when f < 1. ->
      Prim(PMaskOverlay, [|Prim(PResample, [|i; Num f|]);
                           Prim(PResample, [|m; Num f|]);
                           c|])
  | Prim(PResample, [|Prim(PMaskToImage, [|m|]); Num f|]) when f < 1. ->
      Prim(PMaskToImage, [|Prim(PResample, [|m; Num f|])|])
  | Prim(PResample, [|Prim(POpacity, [|i; a|]); Num f|]) when f < 1. ->
      Prim(POpacity, [|Prim(PResample, [|i; Num f|]); a|])
  | Prim(PResample, [|Prim(PPaint, [|b; Array ps|]); Num f|]) when f < 1. ->
      Prim(PPaint, [|Prim(PResample, [|b; Num f|]);
                     Array (Array.map
                              (fun (Point p) -> Point (Point.scale p f))
                              ps)|])
  | Prim(PResample, [|Prim(PSingleColor, [|i; c|]); Num f|]) when f < 1. ->
      Prim(PSingleColor, [|Prim(PResample, [|i; Num f|]); c|])
  | Prim(PResample, [|Prim(PThreshold, [|i; t|]); Num f|]) when f < 1. ->
      Prim(PThreshold, [|Prim(PResample, [|i; Num f|]); t|])
  | Prim(PResample, [|Prim(PThresholdMask, [|i; t|]); Num f|]) when f < 1. ->
      Prim(PThresholdMask, [|Prim(PResample, [|i; Num f|]); t|])
  | Prim(PResample, [|Prim(PTranslate, [|i; Point t|]); Num f|]) when f < 1. ->
      Prim(PTranslate, [|Prim(PResample, [|i; Num f|]); Point (Point.scale t f)|])
  | Prim(PResample, [|Prim(PUnsharpMask, [|i; y; Num r|]); Num f|])
    when f < 1. ->
      Prim(PUnsharpMask, [|Prim(PResample, [|i; Num f|]); y; Num (r *. f)|])

    (* Units *)

    (* Note: it is generally dangerous to remove operators, as *)
    (* this might prevent error propagation from working correctly. *)
    (* Therefore, unit rules should only be defined when the produced *)
    (* expression cannot itself raise an error. *)

  | Prim(PGaussianBlur, [|Prim(PConstantColor, _) as cc; _|]) -> cc
  | Prim(PResample, [|Prim(PConstantColor, _) as cc; _|]) -> cc
  | Prim(PResample, [|Prim(PEmpty, _) as empty; _|]) -> empty
  | Prim(PResample, [|Prim(PFail, _) as fail; _|]) -> fail

    (* Zeroes *)
  | Prim(POpacity, [|_; Num 0.|]) -> Image (Image.empty)
  | Prim(PPaint, [|_; Array [| |] |]) -> Image (Image.empty)

    (* PExtent *)
  | Prim(PExtent, [|Prim(PBlend, [|i1; i2; _|])|]) ->
      Prim(PRectUnion, [|Prim(PExtent, [|i1|]); Prim(PExtent, [|i2|])|])
  | Prim(PExtent, [|Prim(PChannelToMask, [|i;_|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PCheckerboard, _)|]) ->
      Rect (Rect.infinite)
  | Prim(PExtent, [|Prim(PCircle, [|Point c; Num r; _|])|]) ->
      Rect (Rect.make ((Point.x c) -. r) ((Point.y c) -. r) (2. *. r) (2. *. r))
  | Prim(PExtent, [|Prim(PConstantColor, [|Color c|])|]) ->
      Rect (if Color.alpha c == 0.0 then Rect.zero else Rect.infinite)
  | Prim(PExtent, [|Prim(PColorControls, [|i;_;_;_|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PCrop, [|i; r|])|]) ->
      Prim(PRectIntersection, [|Prim(PExtent, [|i|]); r|])
  | Prim(PExtent, [|Prim(PCropOverlay, _)|]) ->
      Rect (Rect.infinite)
  | Prim(PExtent, [|Prim(PEmpty, [||])|]) ->
      Rect (Rect.zero)
  | Prim(PExtent, [|Prim(PGaussianBlur, [|i; Num r|])|]) ->
      Prim(PRectOutset, [|Prim(PExtent, [|i|]); Num r|])
  | Prim(PExtent, [|Prim(PInvert, [|i|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PInvertMask, [|i|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PMask, [|i; m|])|]) ->
      Prim(PRectUnion, [|Prim(PExtent, [|i|]); Prim(PExtent, [|m|])|])
  | Prim(PExtent, [|Prim(PMaskOverlay, [|i; m; _|])|]) ->
      Prim(PRectUnion, [|Prim(PExtent, [|i|]); Prim(PExtent, [|m|])|])
  | Prim(PExtent, [|Prim(PMaskToImage, [|m|])|]) ->
      Prim(PExtent, [|m|])
  | Prim(PExtent, [|Prim(POpacity, [|i; Num a|])|]) ->
      if a = 0.0 then Rect Rect.zero else Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PPaint,[|b;ps|])|]) ->
      Prim(PPaintExtent, [|Prim(PExtent,[|b|]);ps|])
  | Prim(PExtent, [|Prim(PResample, [|i; f|])|]) ->
      Prim(PRectScale, [|Prim(PExtent, [|i|]); f|])
  | Prim(PExtent, [|Prim(PSingleColor, [|i; _|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PThreshold, [|i; _|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PThresholdMask, [|i; _|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PTranslate, [|i; v|])|]) ->
      Prim(PRectTranslate, [|Prim(PExtent, [|i|]); v|])
  | Prim(PExtent, [|Prim(PUnsharpMask, [|i; _; _|])|]) ->
      Prim(PExtent, [|i|])
  | Prim(PExtent, [|Prim(PFail, _)|]) ->
      Rect Rect.zero

    (* Default case *)
  | e -> e

let rec subst arg = function
  | Lambda _ as expr ->
      expr
  | Prim(op, args) ->
      Prim(op, Array.map (subst arg) args)
  | Arg 0 ->
      arg
  | value when Expr.is_value value ->
      value

let rec inline = function
  | Lambda body ->
      Lambda (inline body)
  | Prim(PApply, [| Lambda body; arg |]) ->
      subst (inline arg) (inline body)
  | Prim(PMap, [| Lambda body; Prim(PArrayCreate, elems) |]) ->
      let body' = inline body in
      Prim(PArrayCreate, Array.map (fun arg -> subst (inline arg) body') elems)
  | Prim(op, args) ->
      Prim(op, Array.map inline args)
  | Arg _ as expr ->
      expr
  | value when Expr.is_value value ->
      value

let rec rewrite expr =
  match inline expr with
  | Prim _ as e ->
      begin match rewritePrim e with
        Prim(name, args) ->
          Prim(name, Array.map rewrite args)
      | value -> value
      end
  | e -> e

let verbose_rewrite expr =
  let expr' = rewrite expr in
  print_endline (" Original: " ^ (Printer.to_string expr));
  print_endline ("Optimised: " ^ (Printer.to_string expr'));
  expr'
