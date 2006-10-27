//
//  IFImageCGLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 09.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageCGLayer.h"


@implementation IFImageCGLayer

- (id)initWithCGLayer:(CGLayerRef)theLayer origin:(CGPoint)theOrigin;
{
  if (![super init])
    return nil;
  layer = CGLayerRetain(theLayer);
  image = nil;
  origin = theOrigin;
  return self;
}

- (void)dealloc;
{
  CGLayerRelease(layer);
  if (image != nil) {
    OBJC_RELEASE(image);
  }
  [super dealloc];
}

- (BOOL)isLocked;
{
  return [self retainCount] > 1 || CFGetRetainCount(layer) > 1 || (image != nil && [image retainCount] > 1);
}

- (CGRect)extent;
{
  CGRect extent = { origin, CGLayerGetSize(layer) };
  return extent;
}

- (CIImage*)imageCI;
{
  if (image == nil) {
    image = [CIImage imageWithCGLayer:layer options:[NSDictionary dictionary]]; // TODO color space
    if (!CGPointEqualToPoint(origin,CGPointZero))
      image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(origin.x,origin.y)];
    [image retain];
  }
  return image;
}

- (CGImageRef)imageCG;
{
  NSAssert(NO, @"TODO");
  return nil;
}

@end
