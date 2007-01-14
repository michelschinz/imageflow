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

+ (id)imageRGBAType;
+ (id)maskType;

+ (id)imageTypeWithPixelType:(IFType*)thePixelType;
- (id)initWithPixelType:(IFType*)thePixelType;

- (IFType*)pixelType;

@end
