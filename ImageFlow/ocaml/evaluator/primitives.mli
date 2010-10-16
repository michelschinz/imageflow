(* Warning: any change to the type below must be mirrored in file *)
(* ../../IFExpressionTags.h *)

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

val name: t -> string
