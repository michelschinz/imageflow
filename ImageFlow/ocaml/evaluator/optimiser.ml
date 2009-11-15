open Expr
open Primitives

(* Optimisation by rewriting *)

let rec rewritePrim = function
  | Prim(ArrayGet, [| Prim(ArrayCreate, a); Int i |]) ->
      a.(i)
  | Prim(PTupleGet, [| Prim(PTupleCreate, a); Int i |]) ->
      a.(i)

    (* Commutation with resampling *)
  | Prim(Resample, [|Prim(Blend, [|i1; i2; m|]); Num f|]) when f < 1. ->
      Prim(Blend, [|Prim(Resample, [|i1; Num f|]);
                    Prim(Resample, [|i2; Num f|]); m|])
  | Prim(Resample, [|Prim(ChannelToMask, [|i; c|]); Num f|]) ->
      Prim(ChannelToMask, [|Prim(Resample, [|i; Num f|]); c|])
  | Prim(Resample,
       [|Prim(Checkerboard, [|Point c; c1; c2; Num w; Num s|]); Num f|]) ->
         Prim(Checkerboard,
            [|Point (Point.scale c f); c1; c2; Num (w *. f); Num (s *. f)|])
  | Prim(Resample, [|Prim(Circle, [|Point c; Num r; o|]); Num f|])
    when f < 1. ->
      Prim(Circle, [|Point (Point.scale c f); Num (r *. f); o|])
  | Prim(Resample, [|Prim(ColorControls, [|i; c; b; s|]); Num f|])
    when f < 1. ->
      Prim(ColorControls, [|Prim(Resample, [|i; Num f|]); c; b; s|])
  | Prim(Resample, [|Prim(Crop, [|i; Rect r|]); Num f|]) when f < 1. ->
      Prim(Crop, [|Prim(Resample, [|i; Num f|]); Rect (Rect.scale r f)|])
  | Prim(Resample, [|Prim(CropOverlay, [|i; Rect r|]); Num f|]) when f < 1. ->
      Prim(CropOverlay,
         [|Prim(Resample, [|i; Num f|]); Rect (Rect.scale r f)|])
  | Prim(Resample, [|Prim(GaussianBlur, [|i; Num r|]); Num f|]) when f < 1. ->
      Prim(GaussianBlur, [|Prim(Resample, [|i; Num f|]); Num (r *. f)|])
  | Prim(Resample, [|Prim(Invert, [|i|]); Num f|]) when f < 1. ->
      Prim(Invert, [|Prim(Resample, [|i; Num f|])|])
  | Prim(Resample, [|Prim(InvertMask, [|i|]); Num f|]) when f < 1. ->
      Prim(InvertMask, [|Prim(Resample, [|i; Num f|])|])
  | Prim(Resample, [|Prim(PMask, [|i; m|]); Num f|]) when f < 1. ->
      Prim(PMask, [|Prim(Resample, [|i; Num f|]); Prim(Resample, [|m; Num f|])|])
  | Prim(Resample, [|Prim(MaskOverlay, [|i; m; c|]); Num f|]) when f < 1. ->
      Prim(MaskOverlay, [|Prim(Resample, [|i; Num f|]);
                           Prim(Resample, [|m; Num f|]);
                           c|])
  | Prim(Resample, [|Prim(MaskToImage, [|m|]); Num f|]) when f < 1. ->
      Prim(MaskToImage, [|Prim(Resample, [|m; Num f|])|])
  | Prim(Resample, [|Prim(Opacity, [|i; a|]); Num f|]) when f < 1. ->
      Prim(Opacity, [|Prim(Resample, [|i; Num f|]); a|])
  | Prim(Resample, [|Prim(Paint, [|b; Array ps|]); Num f|]) when f < 1. ->
      Prim(Paint, [|Prim(Resample, [|b; Num f|]);
                    Array (Array.map
                             (fun (Point p) -> Point (Point.scale p f))
                             ps)|])
  | Prim(Resample, [|Prim(SingleColor, [|i; c|]); Num f|]) when f < 1. ->
      Prim(SingleColor, [|Prim(Resample, [|i; Num f|]); c|])
  | Prim(Resample, [|Prim(Threshold, [|i; t|]); Num f|]) when f < 1. ->
      Prim(Threshold, [|Prim(Resample, [|i; Num f|]); t|])
  | Prim(Resample, [|Prim(ThresholdMask, [|i; t|]); Num f|]) when f < 1. ->
      Prim(ThresholdMask, [|Prim(Resample, [|i; Num f|]); t|])
  | Prim(Resample, [|Prim(Translate, [|i; Point t|]); Num f|]) when f < 1. ->
      Prim(Translate, [|Prim(Resample, [|i; Num f|]); Point (Point.scale t f)|])
  | Prim(Resample, [|Prim(UnsharpMask, [|i; y; Num r|]); Num f|])
    when f < 1. ->
      Prim(UnsharpMask, [|Prim(Resample, [|i; Num f|]); y; Num (r *. f)|])

        (* Units *)

        (* Note: it is generally dangerous to remove operators, as *)
        (* this might prevent error propagation from working correctly. *)
        (* Therefore, unit rules should only be defined when the produced *)
        (* expression cannot itself raise an error. *)

  | Prim(GaussianBlur, [|Prim(ConstantColor, _) as cc; _|]) -> cc
  | Prim(Resample, [|Prim(ConstantColor, _) as cc; _|]) -> cc
  | Prim(Resample, [|Prim(Empty, _) as empty; _|]) -> empty
  | Prim(Resample, [|Prim(Fail, _) as fail; _|]) -> fail

        (* Zeroes *)
  | Prim(Opacity, [|_; Num 0.|]) -> Image (Image.empty)
  | Prim(Paint, [|_; Array [| |] |]) -> Image (Image.empty)

        (* Extent *)
  | Prim(Extent, [|Prim(Blend, [|i1; i2; _|])|]) ->
      Prim(RectUnion, [|Prim(Extent, [|i1|]); Prim(Extent, [|i2|])|])
  | Prim(Extent, [|Prim(ChannelToMask, [|i;_|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(Checkerboard, _)|]) ->
      Rect (Rect.infinite)
  | Prim(Extent, [|Prim(Circle, [|Point c; Num r; _|])|]) ->
      Rect (Rect.make ((Point.x c) -. r) ((Point.y c) -. r) (2. *. r) (2. *. r))
  | Prim(Extent, [|Prim(ConstantColor, [|Color c|])|]) ->
      Rect (if Color.alpha c == 0.0 then Rect.zero else Rect.infinite)
  | Prim(Extent, [|Prim(ColorControls, [|i;_;_;_|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(Crop, [|i; r|])|]) ->
      Prim(RectIntersection, [|Prim(Extent, [|i|]); r|])
  | Prim(Extent, [|Prim(CropOverlay, _)|]) ->
      Rect (Rect.infinite)
  | Prim(Extent, [|Prim(Empty, [||])|]) ->
      Rect (Rect.zero)
  | Prim(Extent, [|Prim(GaussianBlur, [|i; Num r|])|]) ->
      Prim(RectOutset, [|Prim(Extent, [|i|]); Num r|])
  | Prim(Extent, [|Prim(Invert, [|i|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(InvertMask, [|i|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(PMask, [|i; m|])|]) ->
      Prim(RectUnion, [|Prim(Extent, [|i|]); Prim(Extent, [|m|])|])
  | Prim(Extent, [|Prim(MaskOverlay, [|i; m; _|])|]) ->
      Prim(RectUnion, [|Prim(Extent, [|i|]); Prim(Extent, [|m|])|])
  | Prim(Extent, [|Prim(MaskToImage, [|m|])|]) ->
      Prim(Extent, [|m|])
  | Prim(Extent, [|Prim(Opacity, [|i; Num a|])|]) ->
      if a = 0.0 then Rect Rect.zero else Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(Paint,[|b;ps|])|]) ->
      Prim(PaintExtent, [|Prim(Extent,[|b|]);ps|])
  | Prim(Extent, [|Prim(Resample, [|i; f|])|]) ->
      Prim(RectScale, [|Prim(Extent, [|i|]); f|])
  | Prim(Extent, [|Prim(SingleColor, [|i; _|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(Threshold, [|i; _|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(ThresholdMask, [|i; _|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(Translate, [|i; v|])|]) ->
      Prim(RectTranslate, [|Prim(Extent, [|i|]); v|])
  | Prim(Extent, [|Prim(UnsharpMask, [|i; _; _|])|]) ->
      Prim(Extent, [|i|])
  | Prim(Extent, [|Prim(Fail, _)|]) ->
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
  | Prim(PMap, [| Lambda body; Prim(ArrayCreate, elems) |]) ->
      let body' = inline body in
      Prim(ArrayCreate, Array.map (fun arg -> subst (inline arg) body') elems)
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
