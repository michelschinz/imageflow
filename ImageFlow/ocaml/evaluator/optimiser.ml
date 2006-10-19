open Expr

(* Optimisation by rewriting *)

let rec rewriteOp = function
    (* Commutation with resampling *)
    Op("resample", [|Op("blend", [|i1; i2; m|]); Num f|]) when f < 1. ->
      Op("blend", [|Op("resample", [|i1; Num f|]);
                    Op("resample", [|i2; Num f|]); m|])
  | Op("resample", [|Op("channel-to-mask", [|i; c|]); Num f|]) ->
      Op("channel-to-mask", [|Op("resample", [|i; Num f|]); c|])
  | Op("resample",
       [|Op("checkerboard", [|Point c; c1; c2; Num w; Num s|]); Num f|]) ->
         Op("checkerboard",
            [|Point (Point.scale c f); c1; c2; Num (w *. f); Num (s *. f)|])
  | Op("resample", [|Op("circle", [|Point c; Num r; o|]); Num f|])
    when f < 1. ->
      Op("circle", [|Point (Point.scale c f); Num (r *. f); o|])
  | Op("resample", [|Op("color-controls", [|i; c; b; s|]); Num f|])
    when f < 1. ->
      Op("color-controls", [|Op("resample", [|i; Num f|]); c; b; s|])
  | Op("resample", [|Op("crop", [|i; Rect r|]); Num f|]) when f < 1. ->
      Op("crop", [|Op("resample", [|i; Num f|]); Rect (Rect.scale r f)|])
  | Op("resample", [|Op("crop-overlay", [|i; Rect r|]); Num f|]) when f < 1. ->
      Op("crop-overlay",
         [|Op("resample", [|i; Num f|]); Rect (Rect.scale r f)|])
  | Op("resample", [|Op("gaussian-blur", [|i; Num r|]); Num f|]) when f < 1. ->
      Op("gaussian-blur", [|Op("resample", [|i; Num f|]); Num (r *. f)|])
  | Op("resample", [|Op("invert", [|i|]); Num f|]) when f < 1. ->
      Op("invert", [|Op("resample", [|i; Num f|])|])
  | Op("resample", [|Op("mask", [|i; m|]); Num f|]) when f < 1. ->
      Op("mask", [|Op("resample", [|i; Num f|]); Op("resample", [|m; Num f|])|])
  | Op("resample", [|Op("mask-overlay", [|i; m; c|]); Num f|]) when f < 1. ->
      Op("mask-overlay", [|Op("resample", [|i; Num f|]);
                           Op("resample", [|m; Num f|]);
                           c|])
  | Op("resample", [|Op("mask-to-image", [|m|]); Num f|]) when f < 1. ->
      Op("mask-to-image", [|Op("resample", [|m; Num f|])|])
  | Op("resample", [|Op("opacity", [|i; a|]); Num f|]) when f < 1. ->
      Op("opacity", [|Op("resample", [|i; Num f|]); a|])
  | Op("resample", [|Op("paint", [|b; Array ps|]); Num f|]) when f < 1. ->
      Op("paint", [|Op("resample", [|b; Num f|]);
                    Array (Array.map
                             (fun (Point p) -> Point (Point.scale p f))
                             ps)|])
  | Op("resample", [|Op("single-color", [|i; c|]); Num f|]) when f < 1. ->
      Op("single-color", [|Op("resample", [|i; Num f|]); c|])
  | Op("resample", [|Op("threshold", [|i; t|]); Num f|]) when f < 1. ->
      Op("threshold", [|Op("resample", [|i; Num f|]); t|])
  | Op("resample", [|Op("translate", [|i; Point t|]); Num f|]) when f < 1. ->
      Op("translate", [|Op("resample", [|i; Num f|]); Point (Point.scale t f)|])
  | Op("resample", [|Op("unsharp-mask", [|i; y; Num r|]); Num f|])
    when f < 1. ->
      Op("unsharp-mask", [|Op("resample", [|i; Num f|]); y; Num (r *. f)|])

        (* Units *)
  | Op("color-controls", [|i; Num 1.; Num 0.; Num 1.|]) -> i
  | Op("gaussian-blur", [|Op("constant-color", _) as cc; _|]) -> cc
  | Op("resample", [|Op("constant-color", _) as cc; _|]) -> cc
  | Op("resample", [|Op("empty", _) as empty; _|]) -> empty
  | Op("resample", [|Op("nop", _) as nop; _|]) -> nop

        (* Zeroes *)
  | Op("gaussian-blur", [|i; Num 0.|]) -> i
  | Op("opacity", [|_; Num 0.|]) -> Image (Image.empty)
  | Op("paint", [|_; Array [| |] |]) -> Image (Image.empty)
  | Op("resample", [| i; Num 1. |]) -> i
  | Op("translate", [|i; Point p|]) when p = Point.zero -> i

        (* Extent *)
  | Op("extent", [|Op("blend", [|i1; i2; _|])|]) ->
      Op("rect-union", [|Op("extent", [|i1|]); Op("extent", [|i2|])|])
  | Op("extent", [|Op("channel-to-mask", [|i;_|])|]) ->
      Op("extent", [|i|])
  | Op("extent", [|Op("checkerboard", _)|]) ->
      Rect (Rect.infinite)
  | Op("extent", [|Op("circle", [|Point c; Num r; _|])|]) ->
      Rect (Rect.make ((Point.x c) -. r) ((Point.y c) -. r) (2. *. r) (2. *. r))
  | Op("extent", [|Op("constant-color", [|Color c|])|]) ->
      Rect (if Color.alpha c == 0.0 then Rect.zero else Rect.infinite)
  | Op("extent", [|Op("color-controls", [|i;_;_;_|])|]) ->
      Op("extent", [|i|])
  | Op("extent", [|Op("crop", [|i; r|])|]) ->
      Op("rect-intersection", [|Op("extent", [|i|]); r|])
  | Op("extent", [|Op("crop-overlay", _)|]) ->
      Rect (Rect.infinite)
  | Op("extent", [|Op("empty", [||])|]) ->
      Rect (Rect.zero)
  | Op("extent", [|Op("gaussian-blur", [|i; Num r|])|]) ->
      Op("rect-outset", [|Op("extent", [|i|]); Num r|])
  | Op("extent", [|Op("invert", [|i|])|]) ->
      Op("extent", [|i|])
  | Op("extent", [|Op("mask", [|i; m|])|]) ->
      Op("rect-union", [|Op("extent", [|i|]); Op("extent", [|m|])|])
  | Op("extent", [|Op("mask-overlay", [|i; m; _|])|]) ->
      Op("rect-union", [|Op("extent", [|i|]); Op("extent", [|m|])|])
  | Op("extent", [|Op("mask-to-image", [|m|])|]) ->
      Op("extent", [|m|])
  | Op("extent", [|Op("opacity", [|i; Num a|])|]) ->
      if a = 0.0 then Rect Rect.zero else Op("extent", [|i|])
  | Op("extent", [|Op("paint",[|b;ps|])|]) ->
      Op("paint-extent", [|Op("extent",[|b|]);ps|])
  | Op("extent", [|Op("resample", [|i; f|])|]) ->
      Op("rect-scale", [|Op("extent", [|i|]); f|])
  | Op("extent", [|Op("single-color", [|i; _|])|]) ->
      Op("extent", [|i|])
  | Op("extent", [|Op("threshold", [|i; _|])|]) ->
      Op("extent", [|i|])
  | Op("extent", [|Op("translate", [|i; v|])|]) ->
      Op("rect-translate", [|Op("extent", [|i|]); v|])
  | Op("extent", [|Op("unsharp-mask", [|i; _; _|])|]) ->
      Op("extent", [|i|])
  | Op("extent", [|Op("nop", _)|]) ->
      Rect Rect.zero

        (* Default case *)
  | e -> e

let rec rewrite = function
    Op _ as e ->
      begin match rewriteOp e with
        Op(name, args) ->
          Op(name, Array.map rewrite args)
      | value -> value
      end
  | e -> e
