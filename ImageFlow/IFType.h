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

- (int)arity;

- (value)asCaml;

// protected
- (value)camlRepresentation;

@end
