//
//  IFImageCIImage.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImage.h"

@interface IFImageCIImage : IFImage {
  CIImage* image;
  BOOL isInfinite;
  CIImageAccumulator* cache;
  unsigned usages;
  unsigned usagesBeforeCache;
}

- (id)initWithCIImage:(CIImage*)theImage;

@end
