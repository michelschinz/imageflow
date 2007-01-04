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
  NSArray* argumentTypes;
  IFType* returnType;
}

+ (id)funTypeWithArgumentTypes:(NSArray*)theArgTypes returnType:(IFType*)theRetType;
- (id)initWithArgumentTypes:(NSArray*)theArgTypes returnType:(IFType*)theRetType;

- (NSArray*)argumentTypes;
- (IFType*)returnType;

@end
