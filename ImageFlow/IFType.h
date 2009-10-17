//
//  IFType.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <caml/mlvalues.h>

@interface IFType : NSObject {
  BOOL camlRepresentationIsValid;
  value camlRepresentation;
}

+ (IFType*)colorRGBAType;
+ (IFType*)rectType;
+ (IFType*)sizeType;
+ (IFType*)pointType;
+ (IFType*)stringType;
+ (IFType*)floatType;
+ (IFType*)intType;
+ (IFType*)boolType;
+ (IFType*)actionType;
+ (IFType*)errorType;

+ (id)typeVariable;
+ (id)funTypeWithArgumentType:(IFType*)theArgType returnType:(IFType*)theRetType;
+ (id)arrayTypeWithContentType:(IFType*)theContentType;
+ (id)tupleTypeWithComponentTypes:(NSArray*)theComponentTypes;

+ (id)imageRGBAType;
+ (id)maskType;
+ (id)imageTypeWithPixelType:(IFType*)thePixelType;

+ (id)typeWithCamlType:(value)camlType;

@property(readonly) BOOL isFunType;
@property(readonly) BOOL isArrayType;
@property(readonly) BOOL isTupleType;
@property(readonly) BOOL isImageRGBAType;
@property(readonly) BOOL isMaskType;

@property(readonly) unsigned arity;
@property(readonly) IFType* resultType;
@property(readonly) IFType* leafType;

- (value)asCaml;

// MARK: -
// MARK: PROTECTED
- (value)camlRepresentation;

@end
