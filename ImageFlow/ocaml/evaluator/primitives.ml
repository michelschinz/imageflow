type t =
  | PApply
  | PArrayCreate
  | PArrayGet
  | PAverage
  | PBlend
  | PChannelToMask
  | PCheckerboard
  | PCircle
  | PColorControls
  | PConstantColor
  | PCrop
  | PCropOverlay
  | PDiv
  | PEmpty
  | PExportActionCreate
  | PExtent
  | PFail
  | PFileExtent
  | PGaussianBlur
  | PHistogramRGB
  | PInvert
  | PInvertMask
  | PMap
  | PMask
  | PMaskOverlay
  | PMaskToImage
  | PMul
  | POpacity
  | PPaint
  | PPaintExtent
  | PPointMul
  | PRectIntersection
  | PRectMul
  | PRectOutset
  | PRectScale
  | PRectTranslate
  | PRectUnion
  | PRectangularWindow
  | PResample
  | PSingleColor
  | PThreshold
  | PThresholdMask
  | PTranslate
  | PTupleCreate
  | PTupleGet
  | PUnsharpMask
  | PZip

let name = function
  | PApply -> "apply"
  | PArrayCreate -> "array-create"
  | PArrayGet -> "array-get"
  | PAverage -> "average"
  | PBlend -> "blend"
  | PChannelToMask -> "channel-to-mask"
  | PCheckerboard -> "checkerboard"
  | PCircle -> "circle"
  | PColorControls -> "color-controls"
  | PConstantColor -> "constant-color"
  | PCrop -> "crop"
  | PCropOverlay -> "crop-overlay"
  | PDiv -> "div"
  | PEmpty -> "empty"
  | PExportActionCreate -> "export-action-create"
  | PExtent -> "extent"
  | PFail -> "fail"
  | PFileExtent -> "file-extent"
  | PGaussianBlur -> "gaussian-blur"
  | PHistogramRGB -> "histogram-rgb"
  | PInvert -> "invert"
  | PInvertMask -> "invert-mask"
  | PMap -> "map"
  | PMask -> "mask"
  | PMaskOverlay -> "mask-overlay"
  | PMaskToImage -> "mask-to-image"
  | PMul -> "mul"
  | POpacity -> "opacity"
  | PPaint -> "paint"
  | PPaintExtent -> "paint-extent"
  | PPointMul -> "point-mul"
  | PRectIntersection -> "rect-intersection"
  | PRectMul -> "rect-mul"
  | PRectOutset -> "rect-outset"
  | PRectScale -> "rect-scale"
  | PRectTranslate -> "rectt-ranslate"
  | PRectUnion -> "rect-union"
  | PRectangularWindow -> "rectangular-window"
  | PResample -> "resample"
  | PSingleColor -> "single-color"
  | PThreshold -> "threshold"
  | PThresholdMask -> "threshold-mask"
  | PTranslate -> "translate"
  | PTupleCreate -> "tuple-create"
  | PTupleGet -> "tuple-get"
  | PUnsharpMask -> "unsharp-mask"
  | PZip -> "zip"
