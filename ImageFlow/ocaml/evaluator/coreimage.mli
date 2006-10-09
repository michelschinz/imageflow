val output_image : [ `CIFilter ] Objc.objc -> [ `CIImage ] Objc.objc
val compositing_filter :
  [ `NSString ] Objc.objc -> Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val affine_transform :
  Image.t -> Affinetransform.t -> [ `CIFilter ] Objc.objc
val blend_color_burn : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_color_dodge : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_darken : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_lighten : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_difference : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_exclusion : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_hard_light : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_soft_light : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_hue : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_saturation : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_color : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_luminosity : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_multiply : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_overlay : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val blend_screen : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val composite_source_over : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val checkerboard : Point.t -> Color.t -> Color.t -> float -> float -> [ `CIFilter ] Objc.objc
val color_controls : Image.t -> float -> float -> float -> [ `CIFilter ] Objc.objc
val constant_color : Color.t -> [ `CIFilter ] Objc.objc
val crop : Image.t -> Rect.t -> [ `CIFilter ] Objc.objc
val crop_overlay : Image.t -> Rect.t -> [ `CIFilter ] Objc.objc
val gaussian_blur : Image.t -> float -> [ `CIFilter ] Objc.objc
val invert : Image.t -> [ `CIFilter ] Objc.objc
val mask : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val mask_overlay : Image.t -> Image.t -> [ `CIFilter ] Objc.objc
val opacity : Image.t -> float -> [ `CIFilter ] Objc.objc
val single_color : Image.t -> Color.t -> [ `CIFilter ] Objc.objc
val threshold : Image.t -> float -> [ `CIFilter ] Objc.objc
val unsharp_mask : Image.t -> float -> float -> [ `CIFilter ] Objc.objc
val random : unit -> [ `CIFilter ] Objc.objc
