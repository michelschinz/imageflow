open Expr
open Primitives

exception EvalError of Expr.t

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
  | Prim(op, args) ->
      eval_prim cache op (Array.map (eval cache env) args)
  | Arg i ->
      List.nth env i
  | other when is_value other ->
      other
  | unknown_expr ->
      failwith ("unable to evaluate expression: "
                ^ (Printer.to_string unknown_expr))

and eval_prim cache op args =
  let out_image filter =
    Image (Image.of_ciimage (Coreimage.output_image filter))
  and out_mask filter =
    Mask (Image.mask_of_ciimage (Coreimage.output_image filter))
  in match (op, args) with
    (* Functional primitives *)
  | PApply, [|Closure (env', b); arg|] ->
      eval cache (arg :: env') b
  | PMap, [|Closure (env', b); Array a|] ->
      Array (Array.map (fun e -> eval cache (e :: env') b) a)

    (* Array primitives *)
  | PArrayCreate, xs ->
      Array xs
  | PArrayGet, [|Array a; Int i|] ->
      a.(i)
  | PZip, boxedArrays ->
      let arrays = Array.map (function Array a -> a) boxedArrays in
      let len = Array.fold_left max 0 (Array.map Array.length arrays) in
      let wget a i = a.(i mod (Array.length a)) in
      Array (Array.init
               len
               (fun i ->
                 match (Array.map (fun a -> wget a i) arrays) with
                 | [| e |] -> e
                 | es -> Tuple es))

    (* Tuple primitives *)
  | PTupleCreate, vs ->
      Tuple vs
  | PTupleGet, [|Tuple t; Int i|] ->
      t.(i)

    (* Action primitives *)
  | PExportActionCreate, [|String f; Image i; Rect r|] ->
      Export.create_action f i r

    (* Rectangle primitives *)
  | PRectIntersection, [|Rect r1; Rect r2|] ->
      Rect (Rect.intersection r1 r2)
  | PRectOutset, [|Rect r; Num d|] ->
      Rect (Rect.outset r d d)
  | PRectScale, [|Rect r; Num f|] ->
      Rect (Rect.scale r f)
  | PRectTranslate, [|Rect r; Point v|] ->
      Rect (Rect.translate r (Point.x v) (Point.y v))
  | PRectUnion, [|Rect r1; Rect r2|] ->
      Rect (Rect.union r1 r2)

    (* Image and mask primitives *)
  | PAverage, [| Array a |] when Marray.for_all is_image a ->
      let a' = Array.map (function Image i -> i) a in
      out_image (Coreimage.average a')
  | PAverage, [| Array a |] when Marray.for_all is_mask a ->
      let a' = Array.map (function Mask i -> i) a in
      out_mask (Coreimage.average a')
  | PBlend, [|Image i1; Image i2; Int m|] ->
      let m' = Nsstring.stringWithUTF8String
          (Blendmode.to_coreimage (Blendmode.of_int m)) in
      out_image (Coreimage.compositing_filter m' i1 i2)
  | PChannelToMask, [|Image i; Int c|] ->
      out_mask (Coreimage.channel_to_mask i c)
  | PCheckerboard, [|Point c; Color c1; Color c2; Num w; Num s|] ->
      out_image (Coreimage.checkerboard c c1 c2 w s)
  | PCircle, [|Point c; Num r; Color o|] ->
      out_image (Coreimage.circle c r o)
  | PConstantColor, [|Color c|] ->
      out_image (Coreimage.constant_color c)
  | PColorControls, [| Image i; Num c; Num b; Num s |] ->
      out_image (Coreimage.color_controls i c b s)
  | PCrop, [|Image i; Rect r|] ->
      out_image (Coreimage.crop i r)
  | PCropOverlay, [|Image i; Rect r|] ->
      out_image (Coreimage.crop_overlay i r)
  | PEmpty, [||] ->
      Image (Image.empty)
  | PExtent, [|Image i|]
  | PExtent, [|Mask i|] ->
      Rect (Image.extent i)
  | PGaussianBlur, [|Image i; Num r|] ->
      out_image (Coreimage.gaussian_blur i r)
  | PGaussianBlur, [|Mask m; Num r|] ->
      out_mask (Coreimage.gaussian_blur m r)
  | PInvert, [|Image i|] ->
      out_image (Coreimage.invert i)
  | PInvertMask, [|Mask m|] ->
      out_mask (Coreimage.invert_mask m)
  | PMask, [|Image i; Mask m|] ->
      out_image (Coreimage.mask i m)
  | PMaskOverlay, [|Image i; Mask m; Color c|] ->
      out_image (Coreimage.mask_overlay i m c)
  | PMaskToImage, [|Mask m|] ->
      out_image (Coreimage.mask_to_image m)
  | POpacity, [|Image i; Num a|] ->
      out_image (Coreimage.opacity i a)
  | PPaint, [|Image b; Array ps|] ->
      Image (Paint.eval_paint b ps)
  | PRectangularWindow, [|Image i; Color c; Rect r; Num m|] ->
      out_image (Coreimage.rectangular_window i c r m)
  | PResample, [|Image i; Num f|] ->
      out_image (Coreimage.affine_transform i (Affinetransform.scale f f))
  | PResample, [|Mask m; Num f|] ->
      out_mask (Coreimage.affine_transform m (Affinetransform.scale f f))
  | PSingleColor, [|Image i; Color c|] ->
      out_image (Coreimage.single_color i c)
  | PThreshold, [|Image i; Num t|] ->
      out_image (Coreimage.threshold i t)
  | PThresholdMask, [|Mask m; Num t|] ->
      out_mask (Coreimage.threshold_mask m t)
  | PTranslate, [|Image i; Point t|] ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_image (Coreimage.affine_transform i at)
  | PTranslate, [|Mask m; Point t|] ->
      let at = Affinetransform.translation (Point.x t) (Point.y t) in
      out_mask (Coreimage.affine_transform m at)
  | PUnsharpMask, [| Image i; Num y; Num r |] ->
      out_image (Coreimage.unsharp_mask i y r)

    (* Miscellaneous primitives *)
  | PPaintExtent, [|_; Array [| |]|] ->
      Rect Rect.zero
  | PPaintExtent, [|Rect r; Array ps|] ->
      let pt = fun (Point p) -> Rect.translate r (Point.x p) (Point.y p) in
      Rect (Array.fold_left
              (fun e p -> Rect.union e (pt p))
              (pt ps.(0))
              ps)
  | PFail, [||] ->
      raise (EvalError (Error None))

  | n, a ->
      print_endline "cannot eval:";
      Printer.print (Prim (n, a));
      failwith "error"
