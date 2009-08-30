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

#import <caml/memory.h>

static void camlTypeToObjcType(value camlType, IFType** objcType);

@implementation IFType

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

- (BOOL) isArrayType;
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
  CAMLlocal1(camlArgTypes);
  
  if (Is_long(camlType))
    *objcType = [IFBasicType basicTypeWithTag:Int_val(camlType)];
  else switch (Tag_val(camlType)) {
    case IFTypeTag_TVar: {
      *objcType = [[[IFTypeVar alloc] initWithIndex:Int_val(Field(camlType,0))] autorelease];
    } break;
    case IFTypeTag_TFun: {
      camlArgTypes = Field(camlType,0);
      NSMutableArray* argTypes = [NSMutableArray array];
      for (int i = 0; i < Wosize_val(camlArgTypes); ++i) {
        IFType* argType = nil;
        camlTypeToObjcType(Field(camlArgTypes,i), &argType);
        [argTypes addObject:argType];
      }
      IFType* retType = nil;
      camlTypeToObjcType(Field(camlType,1), &retType);
      *objcType = [IFFunType funTypeWithArgumentTypes:argTypes returnType:retType];
    } break;
    case IFTypeTag_TArray: {
      IFType* contentType = nil;
      camlTypeToObjcType(Field(camlType,0), &contentType);
      *objcType = [IFArrayType arrayTypeWithContentType:contentType];
    } break;
    case IFTypeTag_TImage: {
      IFType* pixelType = nil;
      camlTypeToObjcType(Field(camlType,0), &pixelType);
      *objcType = [IFImageType imageTypeWithPixelType:pixelType];
    } break;
    default:
      NSCAssert1(NO, @"unexpected type tag (%d)",Tag_val(camlType));
  }
  
  CAMLreturn0;
}

