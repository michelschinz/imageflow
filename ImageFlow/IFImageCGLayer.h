//
//  IFImageCGLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 09.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFImageCGLayer : NSObject {
  CGLayerRef layer;
  CGPoint origin;
  CIImage* image;
}

- (id)initWithCGLayer:(CGLayerRef)theLayer origin:(CGPoint)theOrigin;

@end
