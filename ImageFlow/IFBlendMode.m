/*
 *  IFBlendMode.m
 *  ImageFlow
 *
 *  Created by Michel Schinz on 18.10.06.
 *  Copyright 2006 Michel Schinz. All rights reserved.
 *
 */

#include "IFBlendMode.h"

NSString* NSStringFromBlendMode(IFBlendMode mode) {
  switch (mode) {
  case IFBlendMode_SourceOver:
    return @"over";
  case IFBlendMode_Color:
    return @"color";
  case IFBlendMode_ColorBurn:
    return @"color burn";
  case IFBlendMode_ColorDodge:
    return @"color dodge";
  case IFBlendMode_Darken:
    return @"darken";
  case IFBlendMode_Difference:
    return @"difference";
  case IFBlendMode_Exclusion:
    return @"exclusion";
  case IFBlendMode_HardLight:
    return @"hard light";
  case IFBlendMode_Hue:
    return @"hue";
  case IFBlendMode_Lighten:
    return @"lighten";
  case IFBlendMode_Luminosity:
    return @"luminosity";
  case IFBlendMode_Multiply:
    return @"multiply";
  case IFBlendMode_Overlay:
    return @"overlay";
  case IFBlendMode_Saturation:
    return @"saturation";
  case IFBlendMode_Screen:
    return @"screen";
  case IFBlendMode_SoftLight:
    return @"soft light";
  default:
    NSCAssert1(NO, @"unknown blend mode %d", mode);
    return nil;
  }
}
