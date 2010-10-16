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
  | PExportActionCreate
  | Extent
  | Fail
  | FileExtent
  | GaussianBlur
  | HistogramRGB
  | Invert
  | InvertMask
  | PMap
  | PMask
  | MaskOverlay
  | MaskToImage
  | Mul
  | Opacity
  | Paint
  | PaintExtent
  | PointMul
  | RectIntersection
  | RectMul
  | RectOutset
  | RectScale
  | RectTranslate
  | RectUnion
  | RectangularWindow
  | Resample
  | SingleColor
  | Threshold
  | ThresholdMask
  | Translate
  | PTupleCreate
  | PTupleGet
  | UnsharpMask
  | PZip

val name: t -> string
