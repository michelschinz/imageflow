open Expr
open Primitives

exception EvalError of Expr.t

(* Execution of actions *)

let execute = function
    Prim(Save, [|Image i; String f|]) ->
      Save.exec_save (Image.to_ciimage i) f "public.jpeg"
  | _ -> failwith "internal error"

(* Evaluation of expressions *)

let rec eval cache env expr =
  match env with
    [] -> eval_cached cache expr
  | _ -> eval_really cache env expr

and eval_cached cache expr =
  try
    Cache.lookup cache expr
  with Not_found ->
    let res = eval_really cache [] expr in
    begin match res with
      Image res_image when not (is_value expr) ->
        Cache.store cache expr res_image
    | _ -> ()
    end;
    res

and eval_really cache env expr =
  match expr with
  | Lambda body ->
      Closure (env, body)
  | Map (f, arr) ->
      begin match (eval cache env f, eval cache env arr) with
        Closure (env', b), Array earr ->
          Array (Array.map (fun e -> eval cache (e :: env') b) earr)
      end
  | Apply (f, arg) ->
      begin match (eval cache env f, eval cache env arg) with
        Closure (env', b), earg ->
          eval cache (earg :: env') b
      end
  | Prim(op, args) ->
      let evaluated_args =
        try
          Array.map (eval cache env) args
        with EvalError _ ->
          raise (EvalError (Error None))
      in
      eval_prim op evaluated_args
  | Arg i ->
      List.nth env i
  | other when is_value other ->
      other
  | unknown_expr ->
      failwith ("unable to evaluate expression: "
                ^ (Printer.to_string unknown_expr))

and eval_prim op args =
  let out_image filter =
    Image (Image.of_ciimage (Coreimage.output_image filter))
  and out_mask filter =
    Mask (Image.mask_of_ciimage (Coreimage.output_image filter))
  in match (op, args) with
    (* Array primitives *)
  | ArrayCreate, xs ->
      Array xs
  | ArrayGet, [|Array a; Int i|] ->
      a.(i)

    (* Tuple primitives *)
  | PTupleCreate, vs ->
      Tuple vs
  | PTupleGet, [|Tuple t; Int i|] ->
      t.(i)

    (* Rectangle primitives *)
  | RectIntersection, [|Rect r1; Rect r2|] ->
      Rect (Rect.intersection r1 r2)
  | RectOutset, [|Rect r; Num d|] ->
      Rect (Rect.outset r d d)
  | RectScale, [|Rect r; Num f|] ->
      Rect (Rect.scale r f)
  | RectTranslate, [|Rect r; Point v|] ->
      Rect (Rect.translate r (Point.x v) (Point.y v))
  | RectUnion, [|Rect r1; Rect r2|] ->
      Rect (Rect.union r1 r2)

    (* Image and mask primitives *)
  | Average, [| Array a |] when Marray.for_all is_image a ->
      let a' = Array.map (function Image i -> i) a in
      out_image (Coreimage.average a')
  | Average, [| Array a |] when Marray.for_all is_mask a ->
      let a' = Array.map (function Mask i -> i) a in
      out_mask (Coreimage.average a')
  | Blend, [|Image i1; Image i2; Int m|] ->
      let m' = Nsstring.stringWithUTF8String
          (Blendmode.to_coreimage (Blendmode.of_int m)) in
      out_image (Coreimage.compositing_filter m' i1 i2)
  | ChannelToMask, [|Image i; Int c|] ->
      out_mask (Coreimage.channel_to_mask i c)
  | Checkerboard, [|Point c; Color c1; Color c2; Num w; Num s|] ->
      out_image (Coreimage.checkerboard c c1 c2 w s)
  | Circle, [|Point c; Num r; Color o|] ->
      out_image (Coreimage.circle c r o)
  | ConstantColor, [|Color c|] ->
      out_image (Coreimage.constant_color c)
  | ColorControls, [| Image i; Num c; Num b; Num s |] ->
      out_image (Coreimage.color_controls i c b s)
  | Crop, [|Image i; Rect r|] ->
      out_image (Coreimage.crop i r)
  | CropOverlay, [|Image i; Rect r|] ->
      out_image (Coreimage.crop_overlay i r)
  | Empty, [||] ->
      Image (Image.empty)
  | Extent, [|Image i|]
  | Extent, [|Mask i|] ->
      Rect (Image.extent i)
  | GaussianBlur, [|Image i; Num r|] ->
      out_image (Coreimage.gaussian_blur i r)
  | GaussianBlur, [|Mask m; Num r|] ->
      out_mask (Coreimage.gaussian_blur m r)
  | Invert, [|Image i|] ->
      out_image (Coreimage.invert i)
  | InvertMask, [|Mask m|] ->
      out_mask (Coreimage.invert_mask m)
  | Load, [|String f|] ->
      begin try
        Image (Load.eval_load f)
      with Failure _ ->
        let name = if f = "" then "(no name given)" else f in
        raise (EvalError (Error (Some ("Unable to load file "^name^""))))
      end
  | PMask, [|Image i; Mask m|] ->
      out_image (Coreimage.mask i m)
  | MaskOverlay, [|Image i; Mask m; Color c|] ->
      out_image (Coreimage.mask_overlay i m c)
  | MaskToImage, [|Mask m|] ->
      out_image (Coreimage.mask_to_image m)
  | Opacity, [|Image i; Num a|] ->
      out_image (Coreimage.opacity i a)
  | Paint, [|Image b; Array ps|] ->
      Image (Paint.eval_paint b ps)
  | Print, _ ->
      Action(APrint, execute)
  | RectangularWindow, [|Image i; Color c; Rect r; Num m|] ->
      out_image (Coreimage.rectangular_window i c r m)
  | Resample, [|Image i; Num f|] ->
      out_image (Coreimage.affine_transform i (Affinetransform.scale f f))
  | Resample, [|Mask m; Num f|] ->
      out_mask (Coreimage.affine_transform m (Affinetransform.scale f f))
  | Save, _ ->
      Action(ASave, execute)
  | SingleColor, [|Image i; Color c|] ->
      out_image (Coreimage.single_color i c)
  | Threshold, [|Image i; Num t|] ->
      out_image (Coreimage.threshold i t)
  | ThresholdMask, [|Mask m; Num t|] ->
      out_mask (Coreimage.threshold_mask m t)
  | Translate, [|Image i; Point t|] ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_image (Coreimage.affine_transform i at)
  | Translate, [|Mask m; Point t|] ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_mask (Coreimage.affine_transform m at)
  | UnsharpMask, [| Image i; Num y; Num r |] ->
      out_image (Coreimage.unsharp_mask i y r)

    (* Miscellaneous primitives *)
  | PaintExtent, [|_; Array [| |]|] ->
      Rect Rect.zero
  | PaintExtent, [|Rect r; Array ps|] ->
      let pt = fun (Point p) -> Rect.translate r (Point.x p) (Point.y p) in
      Rect (Array.fold_left
              (fun e p -> Rect.union e (pt p))
              (pt ps.(0))
              ps)
  | Fail, [||] ->
      raise (EvalError (Error None))
