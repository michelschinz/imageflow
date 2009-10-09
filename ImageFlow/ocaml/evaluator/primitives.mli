(* Warning: any change to the type below must be mirrored in file *)
(* ../../IFExpressionTags.h *)

type t =
  | PApply
  | ArrayCreate
  | ArrayGet
  | Average
  | Blend
  | ChannelToMask
  | Checkerboard
  | Circle
  | ColorControls
  | ConstantColor
  | Crop
  | CropOverlay
  | Div
  | Empty
  | Extent
  | Fail
  | FileExtent
  | GaussianBlur
  | HistogramRGB
  | Invert
  | InvertMask
  | Load
  | PMap
  | PMask
  | MaskOverlay
  | MaskToImage
  | Mul
  | Opacity
  | Paint
  | PaintExtent
  | PointMul
  | Print
  | RectIntersection
  | RectMul
  | RectOutset
  | RectScale
  | RectTranslate
  | RectUnion
  | RectangularWindow
  | Resample
  | Save
  | SingleColor
  | Threshold
  | ThresholdMask
  | Translate
  | PTupleCreate
  | PTupleGet
  | UnsharpMask

val name: t -> string
