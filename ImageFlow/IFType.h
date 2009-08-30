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

+ (id)typeWithCamlType:(value)camlType;

@property(readonly) BOOL isArrayType;
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
