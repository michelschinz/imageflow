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
  and filter_for_blend_mode = function
      "color burn" -> Nsstring.stringWithUTF8String "CIColorBurnBlendMode"
    | "color dodge" -> Nsstring.stringWithUTF8String "CIColorDodgeBlendMode"
    | "color" -> Nsstring.stringWithUTF8String "CIColorBlendMode"
    | "darken" -> Nsstring.stringWithUTF8String "CIDarkenBlendMode"
    | "difference" -> Nsstring.stringWithUTF8String "CIDifferenceBlendMode"
    | "exclusion" -> Nsstring.stringWithUTF8String "CIExclusionBlendMode"
    | "hard light" -> Nsstring.stringWithUTF8String "CIHardLightBlendMode"
    | "hue" -> Nsstring.stringWithUTF8String "CIHueBlendMode"
    | "lighten" -> Nsstring.stringWithUTF8String "CILightenBlendMode"
    | "luminosity" -> Nsstring.stringWithUTF8String "CILuminosityBlendMode"
    | "multiply" -> Nsstring.stringWithUTF8String "CIMultiplyBlendMode"
    | "over" -> Nsstring.stringWithUTF8String "CISourceOverCompositing"
    | "overlay" -> Nsstring.stringWithUTF8String "CIOverlayBlendMode"
    | "saturation" -> Nsstring.stringWithUTF8String "CISaturationBlendMode"
    | "screen" -> Nsstring.stringWithUTF8String "CIScreenBlendMode"
    | "soft light" -> Nsstring.stringWithUTF8String "CISoftLightBlendMode"
    | mode -> failwith ("internal error: unknown blend mode " ^ mode)
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

    (* Image operators *)
  | Op("blend", [|Image i1; Image i2; String m|]) ->
      out_image (Coreimage.compositing_filter (filter_for_blend_mode m) i1 i2)
  | Op("checkerboard", [|Point c; Color c1; Color c2; Num w; Num s|]) ->
      out_image (Coreimage.checkerboard c c1 c2 w s)
  | Op("constant-color", [|Color c|]) ->
      out_image (Coreimage.constant_color c)
  | Op("color-controls", [| Image i; Num c; Num b; Num s |]) ->
      out_image (Coreimage.color_controls i c b s)
  | Op("crop", [|Image i; Rect r|]) ->
      out_image (Coreimage.crop i r)
  | Op("crop-overlay", [|Image i; Rect r|]) ->
      out_image (Coreimage.crop_overlay i r)
  | Op("empty", [||]) ->
      out_image (Coreimage.constant_color Color.transparent)
  | Op("extent", [|Image i|]) ->
      Rect (Image.extent i)
  | Op("gaussian-blur", [|Image i; Num r|]) ->
      out_image (Coreimage.gaussian_blur i r)
  | Op("invert", [|Image i|]) ->
      out_image (Coreimage.invert i)
  | Op("load", [|String f; _; _; _; _; _; _; _; _|]) ->
      begin try
        Image (Image.of_cgimage (Load.eval_load f))
      with Failure _ ->
        Error (Some "toto")
      end
  | Op("mask", [|Image i; Mask m|]) ->
      out_image (Coreimage.mask i m)
  | Op("mask-overlay", [|Image i; Mask m|]) ->
      out_image (Coreimage.mask_overlay i m)
  | Op("opacity", [|Image i; Num a|]) ->
      out_image (Coreimage.opacity i a)
  | Op("paint", [|Image b; Array ps|]) ->
      failwith "TODO"
(*       Image (Image.of_cglayer (Paint.eval b ps)) *)
  | Op("print", _) ->
      Action("print", execute)
  | Op("resample", [|Image i; Num f|]) ->
      out_image (Coreimage.affine_transform i (Affinetransform.scale f f))
  | Op("save", _) ->
      Action("save", execute)
  | Op("single-color", [|Image i; Color c|]) ->
      out_image (Coreimage.single_color i c)
  | Op("threshold", [|Image i; Num t|]) ->
      out_image (Coreimage.threshold i t)
  | Op("translate", [|Image i; Point t|]) ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_image (Coreimage.affine_transform i at)
  | Op("unsharp-mask", [| Image i; Num y; Num r |]) ->
      out_image (Coreimage.unsharp_mask i y r)
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
