//
//  IFImageCGImage.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImage.h"

@interface IFImageCGImage : IFImage {
  CGImageRef image;
  CIImage* ciImage;
}

- (id)initWithCGImage:(CGImageRef)theImage kind:(IFImageKind)theKind;

@end
