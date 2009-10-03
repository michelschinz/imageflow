/*
 *  IFExpressionTags.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 29.09.06.
 *  Copyright 2006 Michel Schinz. All rights reserved.
 *
 */

// Warning:
// - the following tags must match the ones in ocaml/evaluator/expr.mli
// - constructors with and without arguments must be enumerated
//   separately

// Constructors with arguments
typedef enum {
  IFExpressionTag_Lambda,
  IFExpressionTag_Map,
  IFExpressionTag_Apply,
  IFExpressionTag_Prim,
  IFExpressionTag_Var,
  IFExpressionTag_Arg,
  IFExpressionTag_Closure,
  IFExpressionTag_Array,
  IFExpressionTag_Tuple,
  IFExpressionTag_Image,
  IFExpressionTag_Mask,
  IFExpressionTag_Color,
  IFExpressionTag_Rect,
  IFExpressionTag_Size,
  IFExpressionTag_Point,
  IFExpressionTag_String,
  IFExpressionTag_Num,
  IFExpressionTag_Int,
  IFExpressionTag_Bool,
  IFExpressionTag_Action,
  IFExpressionTag_Error,
} IFExpressionTag;

// Warning:
// - the following tags must match the ones in ocaml/evaluator/primitives.mli

typedef enum {
  IFPrimitiveTag_ArrayCreate,
  IFPrimitiveTag_ArrayGet,
  IFPrimitiveTag_Average,
  IFPrimitiveTag_Blend,
  IFPrimitiveTag_ChannelToMask,
  IFPrimitiveTag_Checkerboard,
  IFPrimitiveTag_Circle,
  IFPrimitiveTag_ColorControls,
  IFPrimitiveTag_ConstantColor,
  IFPrimitiveTag_Crop,
  IFPrimitiveTag_CropOverlay,
  IFPrimitiveTag_Div,
  IFPrimitiveTag_Empty,
  IFPrimitiveTag_Extent,
  IFPrimitiveTag_Fail,
  IFPrimitiveTag_FileExtent,
  IFPrimitiveTag_GaussianBlur,
  IFPrimitiveTag_HistogramRGB,
  IFPrimitiveTag_Invert,
  IFPrimitiveTag_InvertMask,
  IFPrimitiveTag_Load,
  IFPrimitiveTag_Mask,
  IFPrimitiveTag_MaskOverlay,
  IFPrimitiveTag_MaskToImage,
  IFPrimitiveTag_Mul,
  IFPrimitiveTag_Opacity,
  IFPrimitiveTag_Paint,
  IFPrimitiveTag_PaintExtent,
  IFPrimitiveTag_PointMul,
  IFPrimitiveTag_Print,
  IFPrimitiveTag_RectIntersection,
  IFPrimitiveTag_RectMul,
  IFPrimitiveTag_RectOutset,
  IFPrimitiveTag_RectScale,
  IFPrimitiveTag_RectTranslate,
  IFPrimitiveTag_RectUnion,
  IFPrimitiveTag_RectangularWindow,
  IFPrimitiveTag_Resample,
  IFPrimitiveTag_Save,
  IFPrimitiveTag_SingleColor,
  IFPrimitiveTag_Threshold,
  IFPrimitiveTag_ThresholdMask,
  IFPrimitiveTag_Translate,
  IFPrimitiveTag_PTupleCreate,
  IFPrimitiveTag_PTupleGet,
  IFPrimitiveTag_UnsharpMask,
} IFPrimitiveTag;
