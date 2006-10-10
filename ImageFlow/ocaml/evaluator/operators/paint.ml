open Expr
open Objc
open Corefoundation
open Bigarray

external cg_paint: [ `IFImage ] objc -> (float, float32_elt, c_layout) Array1.t -> [ `IFImage ] objc
    = "cg_paint"

let eval_paint brush points =
  match points with
    [| |] ->
      Image.empty
  | [| Point p |] ->
      let trans = Affinetransform.translation (Point.x p) (Point.y p) in
      Image.of_ciimage (Coreimage.output_image
                          (Coreimage.affine_transform brush trans))
  | points ->
      let flatPoints = Array1.create float32 c_layout (2*(Array.length points))
      in
      for i = 0 to pred (Array.length points) do
        let Point p = points.(i) in
        flatPoints.{2 * i} <- Point.x p;
        flatPoints.{2 * i + 1} <- Point.y p
      done;
      Image.of_ifimage (cg_paint (Image.to_ifimage brush) flatPoints)
