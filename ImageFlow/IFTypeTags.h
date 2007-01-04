/*
 *  IFTypeTags.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 04.01.07.
 *  Copyright 2007 Michel Schinz. All rights reserved.
 *
 */

// Warning:
// - these tags must match the ones in ocaml/evaluator/type.mli
// - constructors with and without arguments must be enumerated
//   separately

typedef enum {
  IFTypeTag_TImage,
  IFTypeTag_TMask,
  IFTypeTag_TColor,
  IFTypeTag_TRect,
  IFTypeTag_TSize,
  IFTypeTag_TPoint,
  IFTypeTag_TString,
  IFTypeTag_TNum,
  IFTypeTag_TInt,
  IFTypeTag_TBool,
  IFTypeTag_TAction,
  IFTypeTag_TError
} IFParameterlessTypeTag;

typedef enum {
  IFTypeTag_TVar,
  IFTypeTag_TFun,
  IFTypeTag_TArray
} IFParametrisedTypeTag;
