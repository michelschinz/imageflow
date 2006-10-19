type t =
    SourceOver
  | Color
  | ColorBurn
  | ColorDodge
  | Darken
  | Difference
  | Exclusion
  | HardLight
  | Hue
  | Lighten
  | Luminosity
  | Multiply
  | Overlay
  | Saturation
  | Screen
  | SoftLight

let all_modes = [|
  SourceOver;
  Color;
  ColorBurn;
  ColorDodge;
  Darken;
  Difference;
  Exclusion;
  HardLight;
  Hue;
  Lighten;
  Luminosity;
  Multiply;
  Overlay;
  Saturation;
  Screen;
  SoftLight
|]

let of_int i = all_modes.(i)
let to_int b = Marray.index b all_modes

let to_coreimage = function
    SourceOver -> "CISourceOverCompositing";
  | Color -> "CIColorBlendMode"
  | ColorBurn -> "CIColorBurnBlendMode"
  | ColorDodge -> "CIColorDodgeBlendMode"
  | Darken -> "CIDarkenBlendMode"
  | Difference -> "CIDifferenceBlendMode"
  | Exclusion -> "CIExclusionBlendMode"
  | HardLight -> "CIHardLightBlendMode"
  | Hue -> "CIHueBlendMode"
  | Lighten -> "CILightenBlendMode"
  | Luminosity -> "CILuminosityBlendMode"
  | Multiply -> "CIMultiplyBlendMode"
  | Overlay -> "CIOverlayBlendMode"
  | Saturation -> "CISaturationBlendMode"
  | Screen -> "CIScreenBlendMode"
  | SoftLight -> "CISoftLightBlendMode"
