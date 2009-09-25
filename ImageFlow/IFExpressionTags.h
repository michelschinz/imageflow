/*
 *  IFExpressionTags.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 29.09.06.
 *  Copyright 2006 Michel Schinz. All rights reserved.
 *
 */

// Warning:
// - those tags must match the ones in ocaml/evaluator/expr.mli
// - constructors with and without arguments must be enumerated
//   separately

// Constructors with arguments
typedef enum {
  IFExpressionTag_Op,
  IFExpressionTag_Var,
  IFExpressionTag_Arg,
  IFExpressionTag_Array,
  IFExpressionTag_Lambda,
  IFExpressionTag_Let,
  IFExpressionTag_Closure,
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
  IFExpressionTag_Error
} IFExpressionTag;
