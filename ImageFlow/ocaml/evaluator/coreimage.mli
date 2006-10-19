open Objc

val output_image : [ `CIFilter ] objc -> [ `CIImage ] objc
val compositing_filter :
  [ `NSString ] objc -> Image.t -> Image.t -> [ `CIFilter ] objc
val affine_transform :
  Image.t -> Affinetransform.t -> [ `CIFilter ] objc
val blend_color_burn : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_color_dodge : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_darken : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_lighten : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_difference : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_exclusion : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_hard_light : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_soft_light : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_hue : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_saturation : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_color : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_luminosity : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_multiply : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_overlay : Image.t -> Image.t -> [ `CIFilter ] objc
val blend_screen : Image.t -> Image.t -> [ `CIFilter ] objc
val composite_source_over : Image.t -> Image.t -> [ `CIFilter ] objc
val channel_to_mask : Image.t -> int -> [ `CIFilter ] objc
val checkerboard : Point.t -> Color.t -> Color.t -> float -> float -> [ `CIFilter ] objc
val circle : Point.t -> float -> Color.t -> [ `CIFilter ] objc
val color_controls : Image.t -> float -> float -> float -> [ `CIFilter ] objc
val constant_color : Color.t -> [ `CIFilter ] objc
val crop : Image.t -> Rect.t -> [ `CIFilter ] objc
val crop_overlay : Image.t -> Rect.t -> [ `CIFilter ] objc
val gaussian_blur : Image.t -> float -> [ `CIFilter ] objc
val invert : Image.t -> [ `CIFilter ] objc
val invert_mask : Image.t -> [ `CIFilter ] objc
val mask : Image.t -> Image.t -> [ `CIFilter ] objc
val mask_overlay : Image.t -> Image.t -> Color.t -> [ `CIFilter ] objc
val mask_to_image : Image.t -> [ `CIFilter ] objc
val opacity : Image.t -> float -> [ `CIFilter ] objc
val single_color : Image.t -> Color.t -> [ `CIFilter ] objc
val threshold : Image.t -> float -> [ `CIFilter ] objc
val threshold_mask : Image.t -> float -> [ `CIFilter ] objc
val unsharp_mask : Image.t -> float -> float -> [ `CIFilter ] objc
val random : unit -> [ `CIFilter ] objc
