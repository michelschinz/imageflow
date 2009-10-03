type t =
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

let name = function
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
  | Extent -> "extent"
  | Fail -> "fail"
  | FileExtent -> "file-extent"
  | GaussianBlur -> "gaussian-blur"
  | HistogramRGB -> "histogram-rgb"
  | Invert -> "invert"
  | InvertMask -> "invert-mask"
  | Load -> "load"
  | PMask -> "mask"
  | MaskOverlay -> "mask-overlay"
  | MaskToImage -> "mask-to-image"
  | Mul -> "mul"
  | Opacity -> "opacity"
  | Paint -> "paint"
  | PaintExtent -> "paint-extent"
  | PointMul -> "point-mul"
  | Print -> "print"
  | RectIntersection -> "rect-intersection"
  | RectMul -> "rect-mul"
  | RectOutset -> "rect-outset"
  | RectScale -> "rect-scale"
  | RectTranslate -> "rectt-ranslate"
  | RectUnion -> "rect-union"
  | RectangularWindow -> "rectangular-window"
  | Resample -> "resample"
  | Save -> "save"
  | SingleColor -> "single-color"
  | Threshold -> "threshold"
  | ThresholdMask -> "threshold-mask"
  | Translate -> "translate"
  | PTupleCreate -> "tuple-create"
  | PTupleGet -> "tuple-get"
  | UnsharpMask -> "unsharp-mask"
