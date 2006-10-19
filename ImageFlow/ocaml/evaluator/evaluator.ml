open Expr

(* Execution of actions *)

let execute = function
    Op("save", [|Image i; String f|]) ->
      Save.exec_save (Image.to_ciimage i) f "public.jpeg"
  | _ -> failwith "internal error"

(* Evaluation of expressions *)

let eval expr =
  let out_image filter =
    Image (Image.of_ciimage (Coreimage.output_image filter))
  and out_mask filter =
    Mask (Image.of_ciimage (Coreimage.output_image filter))
  in match expr with
    (* Rectangle operators *)
    Op("rect-intersection", [|Rect r1; Rect r2|]) ->
      Rect (Rect.intersection r1 r2)
  | Op("rect-outset", [|Rect r; Num d|]) ->
      Rect (Rect.outset r d d)
  | Op("rect-scale", [|Rect r; Num f|]) ->
      Rect (Rect.scale r f)
  | Op("rect-translate", [|Rect r; Point v|]) ->
      Rect (Rect.translate r (Point.x v) (Point.y v))
  | Op("rect-union", [|Rect r1; Rect r2|]) ->
      Rect (Rect.union r1 r2)

    (* Image and mask operators *)
  | Op("blend", [|Image i1; Image i2; Int m|]) ->
      let m' = Nsstring.stringWithUTF8String
          (Blendmode.to_coreimage (Blendmode.of_int m)) in
      out_image (Coreimage.compositing_filter m' i1 i2)
  | Op("channel-to-mask", [|Image i; Int c|]) ->
      out_mask (Coreimage.channel_to_mask i c)
  | Op("checkerboard", [|Point c; Color c1; Color c2; Num w; Num s|]) ->
      out_image (Coreimage.checkerboard c c1 c2 w s)
  | Op("circle", [|Point c; Num r; Color o|]) ->
      out_image (Coreimage.circle c r o)
  | Op("constant-color", [|Color c|]) ->
      out_image (Coreimage.constant_color c)
  | Op("color-controls", [| Image i; Num c; Num b; Num s |]) ->
      out_image (Coreimage.color_controls i c b s)
  | Op("crop", [|Image i; Rect r|]) ->
      out_image (Coreimage.crop i r)
  | Op("crop-overlay", [|Image i; Rect r|]) ->
      out_image (Coreimage.crop_overlay i r)
  | Op("empty", [||]) ->
      Image (Image.empty)
  | Op("extent", [|Image i|])
  | Op("extent", [|Mask i|]) ->
      Rect (Image.extent i)
  | Op("gaussian-blur", [|Image i; Num r|]) ->
      out_image (Coreimage.gaussian_blur i r)
  | Op("gaussian-blur", [|Mask m; Num r|]) ->
      out_mask (Coreimage.gaussian_blur m r)
  | Op("invert", [|Image i|]) ->
      out_image (Coreimage.invert i)
  | Op("invert", [|Mask m|]) ->
      out_mask (Coreimage.invert_mask m)
  | Op("load", [|String f; _; _; _; _; _; _; _; _|]) ->
      begin try
        Image (Load.eval_load f)
      with Failure _ ->
        Error (Some "toto")
      end
  | Op("mask", [|Image i; Mask m|]) ->
      out_image (Coreimage.mask i m)
  | Op("mask-overlay", [|Image i; Mask m; Color c|]) ->
      out_image (Coreimage.mask_overlay i m c)
  | Op("mask-to-image", [|Mask m|]) ->
      out_image (Coreimage.mask_to_image m)
  | Op("opacity", [|Image i; Num a|]) ->
      out_image (Coreimage.opacity i a)
  | Op("paint", [|Image b; Array ps|]) ->
      Image (Paint.eval_paint b ps)
  | Op("print", _) ->
      Action(Print, execute)
  | Op("resample", [|Image i; Num f|]) ->
      out_image (Coreimage.affine_transform i (Affinetransform.scale f f))
  | Op("resample", [|Mask m; Num f|]) ->
      out_mask (Coreimage.affine_transform m (Affinetransform.scale f f))
  | Op("save", _) ->
      Action(Save, execute)
  | Op("single-color", [|Image i; Color c|]) ->
      out_image (Coreimage.single_color i c)
  | Op("threshold", [|Image i; Num t|]) ->
      out_image (Coreimage.threshold i t)
  | Op("threshold", [|Mask m; Num t|]) ->
      out_mask (Coreimage.threshold_mask m t)
  | Op("translate", [|Image i; Point t|]) ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_image (Coreimage.affine_transform i at)
  | Op("translate", [|Mask m; Point t|]) ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_mask (Coreimage.affine_transform m at)
  | Op("unsharp-mask", [| Image i; Num y; Num r |]) ->
      out_image (Coreimage.unsharp_mask i y r)

        (* Miscellaneous operators *)
  | Op("paint-extent", [|_; Array [| |]|]) ->
      Rect Rect.zero
  | Op("paint-extent", [|Rect r; Array ps|]) ->
      let pt = fun (Point p) -> Rect.translate r (Point.x p) (Point.y p) in
      Rect (Array.fold_left
              (fun e p -> Rect.union e (pt p))
              (pt ps.(0))
              ps)
  | Op("nop", _) ->
      Error None                        (* TODO *)
  | Var _ ->
      Error None                        (* TODO *)
  | Parent _ ->
      Error None                        (* TODO *)
  | other when is_value other ->
      other
  | unknown_expr ->
      failwith ("unable to evaluate expression: "
                ^ (Printer.to_string unknown_expr))
