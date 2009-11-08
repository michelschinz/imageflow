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

let name = function
  | PApply -> "apply"
  | ArrayCreate -> "array-create"
  | ArrayGet -> "array-get"
  | Average -> "average"
  | Blend -> "blend"
  | ChannelToMask -> "channel-to-mask"
  | Checkerboard -> "checkerboard"
  | Circle -> "circle"
  | ColorControls -> "color-controls"
  | ConstantColor -> "constant-color"
  | Crop -> "crop"
  | CropOverlay -> "crop-overlay"
  | Div -> "div"
  | Empty -> "empty"
  | PExportActionCreate -> "export-action-create"
  | Extent -> "extent"
  | Fail -> "fail"
  | FileExtent -> "file-extent"
  | GaussianBlur -> "gaussian-blur"
  | HistogramRGB -> "histogram-rgb"
  | Invert -> "invert"
  | InvertMask -> "invert-mask"
  | Load -> "load"
  | PMap -> "map"
  | PMask -> "mask"
  | MaskOverlay -> "mask-overlay"
  | MaskToImage -> "mask-to-image"
  | Mul -> "mul"
  | Opacity -> "opacity"
  | Paint -> "paint"
  | PaintExtent -> "paint-extent"
  | PointMul -> "point-mul"
  | RectIntersection -> "rect-intersection"
  | RectMul -> "rect-mul"
  | RectOutset -> "rect-outset"
  | RectScale -> "rect-scale"
  | RectTranslate -> "rectt-ranslate"
  | RectUnion -> "rect-union"
  | RectangularWindow -> "rectangular-window"
  | Resample -> "resample"
  | SingleColor -> "single-color"
  | Threshold -> "threshold"
  | ThresholdMask -> "threshold-mask"
  | Translate -> "translate"
  | PTupleCreate -> "tuple-create"
  | PTupleGet -> "tuple-get"
  | UnsharpMask -> "unsharp-mask"
  | PZip -> "zip"
