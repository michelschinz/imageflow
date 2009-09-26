//
//  IFImageType.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFType.h"

@interface IFImageType : IFType {
  IFType* pixelType;
}

- (id)initWithPixelType:(IFType*)thePixelType;

- (IFType*)pixelType;

@end
