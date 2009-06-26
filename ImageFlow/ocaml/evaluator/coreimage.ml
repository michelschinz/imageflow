let (!@) = Nsstring.stringWithUTF8String

let (@@@) f g x = f (g x)

let filter name k a1 =
  k (fun x -> x) (Cifilter.filterWithName name) a1

let array key k filter array =
  let nsArray = Nsmutablearray.array() in
  Array.iter
    (fun image ->
      Nsmutablearray.addImage ~array:nsArray ~image:(Image.to_ciimage image))
    array;
  Cifilter.setArray ~filter:filter ~array:nsArray ~key:key;
  k filter

let image key k filter image =
  Cifilter.setImage ~filter:filter ~image:(Image.to_ciimage image) ~key:key;
  k filter

let color key k filter color =
  let (r, g, b, a) = Color.components color in
  let cicolor = Cicolor.colorWithRedGreenBlueAlpha r g b a in
  Cifilter.setColor ~filter:filter ~color:cicolor ~key:key;
  k filter

let point key k filter pt =
  let (x,y) = Point.components pt in
  let vector = Civector.vectorWithXYZW x y 0. 0. in
  Cifilter.setVector ~filter:filter ~vector:vector ~key:key;
  k filter

let rectangle key k filter rect =
  let (x,y,w,h) = Rect.components rect in
  let vector = Civector.vectorWithXYZW x y w h in
  Cifilter.setVector ~filter:filter ~vector:vector ~key:key;
  k filter

let transform key k filter tform =
  let nstransform = Nsaffinetransform.transform () in
  Nsaffinetransform.setTransformStruct
    nstransform
    (Affinetransform.components_array tform);
  Cifilter.setTransform ~filter:filter ~transform:nstransform ~key:key;
  k filter

let number key k filter number =
  let nsnumber = Nsnumber.numberWithDouble number in
  Cifilter.setNumber ~filter:filter ~number:nsnumber ~key:key;
  k filter

let integer key k filter number =
  let nsnumber = Nsnumber.numberWithInt number in
  Cifilter.setNumber ~filter:filter ~number:nsnumber ~key:key;
  k filter

let string key k filter string =
  let nsstring = Nsstring.stringWithUTF8String string in
  Cifilter.setString ~filter:filter ~string:nsstring ~key:key;
  k filter

let parameterless k filter () = k filter

let output_image f =
  Cifilter.imageForKey f !@"outputImage"

let compositing_filter name =
  filter name (image !@"inputBackgroundImage" @@@ image !@"inputImage")

let affine_transform =
  filter !@"CIAffineTransform" (image !@"inputImage"
                                @@@ transform !@"inputTransform")

let average =
  filter !@"IFAverage" (array !@"inputImages")

let blend_color_burn = compositing_filter !@"CIColorBurnBlendMode"
let blend_color_dodge = compositing_filter !@"CIColorDodgeBlendMode"
let blend_darken = compositing_filter !@"CIDarkenBlendMode" 
let blend_lighten = compositing_filter !@"CILightenBlendMode"
let blend_difference = compositing_filter !@"CIDifferenceBlendMode"
let blend_exclusion = compositing_filter !@"CIExclusionBlendMode"
let blend_hard_light = compositing_filter !@"CIHardLightBlendMode"
let blend_soft_light = compositing_filter !@"CISoftLightBlendMode"
let blend_hue = compositing_filter !@"CIHueBlendMode"
let blend_saturation = compositing_filter !@"CISaturationBlendMode"
let blend_color = compositing_filter !@"CIColorBlendMode"
let blend_luminosity = compositing_filter !@"CILuminosityBlendMode"
let blend_multiply = compositing_filter !@"CIMultiplyBlendMode"
let blend_overlay = compositing_filter !@"CIOverlayBlendMode"
let blend_screen = compositing_filter !@"CIScreenBlendMode"
let composite_source_over = compositing_filter !@"CISourceOverCompositing"

let channel_to_mask =
  filter !@"IFChannelToMask" (image !@"inputImage"
                              @@@ integer !@"inputChannel")

let checkerboard =
  filter !@"CICheckerboardGenerator" (point !@"inputCenter"
                                      @@@ color !@"inputColor0"
                                      @@@ color !@"inputColor1"
                                      @@@ number !@"inputWidth"
                                      @@@ number !@"inputSharpness")

let circle =
  filter !@"IFCircleGenerator" (point !@"inputCenter"
                                @@@ number !@"inputRadius"
                                @@@ color !@"inputColor")

let color_controls =
  filter !@"CIColorControls" (image !@"inputImage"
                              @@@ number !@"inputContrast"
                              @@@ number !@"inputBrightness"
                              @@@ number !@"inputSaturation")

let constant_color =
  filter !@"CIConstantColorGenerator" (color !@"inputColor")

let crop =
  filter !@"CICrop" (image !@"inputImage" @@@ rectangle !@"inputRectangle")

let crop_overlay =
  filter !@"IFCropOverlay" (image !@"inputImage"
                            @@@ rectangle !@"inputRectangle")

let gaussian_blur =
  filter !@"CIGaussianBlur" (image !@"inputImage" @@@ number !@"inputRadius")

let invert =
  filter !@"CIColorInvert" (image !@"inputImage")

let invert_mask =
  filter !@"IFMaskInvert" (image !@"inputImage")

let mask =
  filter !@"IFMask" (image !@"inputImage" @@@ image !@"inputMask")

let mask_overlay =
  filter !@"IFMaskOverlay" (image !@"inputImage"
                            @@@ image !@"inputMask"
                            @@@ color !@"inputColor")

let mask_to_image =
  filter !@"IFMaskToImage" (image !@"inputMask")

let opacity =
  filter !@"IFSetAlpha" (image !@"inputImage" @@@ number !@"inputAlpha")

let rectangular_window =
  filter !@"IFRectangularWindow" (image !@"inputImage"
                                  @@@ color !@"inputMaskColor"
                                  @@@ rectangle !@"inputCutoutRectangle"
                                  @@@ number !@"inputCutoutMargin")

let single_color =
  filter !@"IFSingleColor" (image !@ "inputImage" @@@ color !@"inputColor")

let threshold =
  filter !@"IFThreshold" (image !@"inputImage" @@@ number !@"inputThreshold")

let threshold_mask =
  filter !@"IFMaskThreshold" (image !@"inputImage"
                              @@@ number !@"inputThreshold")

let unsharp_mask =
  filter !@"CIUnsharpMask" (image !@"inputImage"
                            @@@ number !@"inputIntensity"
                            @@@ number !@"inputRadius")

let random =
  filter !@"CIRandomGenerator" parameterless

