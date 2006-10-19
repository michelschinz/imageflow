/*
 *  IFBlendMode.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 18.10.06.
 *  Copyright 2006 Michel Schinz. All rights reserved.
 *
 */

// Warning:
// - those tags must match the ones in ocaml/evaluator/blendmode.mli

typedef enum {
  IFBlendMode_SourceOver,
  IFBlendMode_Color,
  IFBlendMode_ColorBurn,
  IFBlendMode_ColorDodge,
  IFBlendMode_Darken,
  IFBlendMode_Difference,
  IFBlendMode_Exclusion,
  IFBlendMode_HardLight,
  IFBlendMode_Hue,
  IFBlendMode_Lighten,
  IFBlendMode_Luminosity,
  IFBlendMode_Multiply,
  IFBlendMode_Overlay,
  IFBlendMode_Saturation,
  IFBlendMode_Screen,
  IFBlendMode_SoftLight
} IFBlendMode;

NSString* NSStringFromBlendMode(IFBlendMode mode);
