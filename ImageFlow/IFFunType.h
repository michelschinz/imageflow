//
//  IFFunType.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFType.h"

@interface IFFunType : IFType {
  IFType* argumentType;
  IFType* returnType;
}

- (id)initWithArgumentType:(IFType*)theArgType returnType:(IFType*)theRetType;

@property(readonly) IFType* argumentType;
@property(readonly) IFType* returnType;

@end
