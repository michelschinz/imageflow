//
//  IFType.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFType.h"
#import "IFBasicType.h"
#import "IFTypeVar.h"
#import "IFFunType.h"
#import "IFArrayType.h"
#import "IFImageType.h"
#import "IFTupleType.h"

#import <caml/memory.h>

static void camlTypeToObjcType(value camlType, IFType** objcType);

@implementation IFType

+ (IFType*)colorRGBAType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TColor_RGBA];
}

+ (IFType*)rectType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TRect];
}

+ (IFType*)sizeType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TSize];
}

+ (IFType*)pointType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TPoint];
}

+ (IFType*)stringType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TString];
}

+ (IFType*)floatType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TFloat];
}

+ (IFType*)intType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TInt];
}

+ (IFType*)boolType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TBool];
}

+ (IFType*)actionType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TAction];
}

+ (IFType*)errorType;
{
  return [IFBasicType basicTypeWithTag:IFTypeTag_TError];
}

+ (id)typeVariable;
{
  return [IFTypeVar typeVariable];
}

+ (id)funTypeWithArgumentType:(IFType*)theArgType returnType:(IFType*)theRetType;
{
  return [[[IFFunType alloc] initWithArgumentType:theArgType returnType:theRetType] autorelease];
}

+ (id)arrayTypeWithContentType:(IFType*)theContentType;
{
  return [[[IFArrayType alloc] initWithContentType:theContentType] autorelease];
}

+ (id)tupleTypeWithComponentTypes:(NSArray*)theComponentTypes;
{
  return [[[IFTupleType alloc] initWithComponentTypes:theComponentTypes] autorelease];
}

+ (id)imageRGBAType;
{
  static IFImageType* t = nil;
  if (t == nil)
    t = [self imageTypeWithPixelType:[IFBasicType colorRGBAType]];
  return t;
}

+ (id)maskType;
{
  static IFImageType* t = nil;
  if (t == nil)
    t = [self imageTypeWithPixelType:[IFBasicType floatType]];
  return t;
}

+ (id)imageTypeWithPixelType:(IFType*)thePixelType;
{
  return [[[IFImageType alloc] initWithPixelType:thePixelType] autorelease];
}

+ (id)typeWithCamlType:(value)camlType;
{
  IFType* type = nil;
  camlTypeToObjcType(camlType, &type);
  return type;
}

- (void)dealloc;
{
  if (camlRepresentationIsValid) {
    caml_remove_global_root(&camlRepresentation);
    camlRepresentation = 0;
    camlRepresentationIsValid = NO;
  }
  [super dealloc];
}

- (BOOL)isArrayType;
{
  return NO;
}

- (BOOL)isTupleType;
{
  return NO;
}

- (BOOL)isFunType;
{
  return NO;
}

- (BOOL)isActionType;
{
  return NO;
}

- (BOOL)isSomeImageType;
{
  return NO;
}

- (BOOL)isImageRGBAType;
{
  return NO;
}

- (BOOL)isMaskType;
{
  return NO;
}

- (unsigned)arity;
{
  [self doesNotRecognizeSelector:_cmd];
  return 0;
}

- (IFType*)resultType;
{
  return self;
}

- (IFType*)leafType;
{
  return self;
}

- (value)asCaml;
{
  if (!camlRepresentationIsValid) {
    caml_register_global_root(&camlRepresentation);
    camlRepresentation = [self camlRepresentation];
    camlRepresentationIsValid = YES;
  }
  return camlRepresentation;
}

// MARK: -
// MARK: PROTECTED

- (value)camlRepresentation;
{
  [self doesNotRecognizeSelector:_cmd];
  return Val_unit;
}

@end

static void camlTypeToObjcType(value camlType, IFType** objcType) {
  CAMLparam1(camlType);
  CAMLlocal1(camlComponentTypes);
  
  if (Is_long(camlType))
    *objcType = [IFBasicType basicTypeWithTag:Int_val(camlType)];
  else switch (Tag_val(camlType)) {
    case IFTypeTag_TVar: {
      *objcType = [[[IFTypeVar alloc] initWithIndex:Int_val(Field(camlType,0))] autorelease];
    } break;
    case IFTypeTag_TFun: {
      IFType* argType = nil;
      camlTypeToObjcType(Field(camlType, 0), &argType);
      IFType* retType = nil;
      camlTypeToObjcType(Field(camlType, 1), &retType);
      *objcType = [IFType funTypeWithArgumentType:argType returnType:retType];
    } break;
    case IFTypeTag_TArray: {
      IFType* contentType = nil;
      camlTypeToObjcType(Field(camlType,0), &contentType);
      *objcType = [IFType arrayTypeWithContentType:contentType];
    } break;
    case IFTypeTag_TTuple: {
      camlComponentTypes = Field(camlType,0);
      NSMutableArray* componentTypes = [NSMutableArray array];
      for (int i = 0; i < Wosize_val(camlComponentTypes); ++i) {
        IFType* argType = nil;
        camlTypeToObjcType(Field(camlComponentTypes,i), &argType);
        [componentTypes addObject:argType];
      }
      *objcType = [IFType tupleTypeWithComponentTypes:componentTypes];
    } break;
    case IFTypeTag_TImage: {
      IFType* pixelType = nil;
      camlTypeToObjcType(Field(camlType,0), &pixelType);
      *objcType = [IFType imageTypeWithPixelType:pixelType];
    } break;
    default:
      NSCAssert1(NO, @"unexpected type tag (%d)",Tag_val(camlType));
  }
  
  CAMLreturn0;
}

