//
//  IFImageCIImage.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageCIImage.h"

@interface IFImageCIImage (Private)
- (void)incrementUsagesAndCacheIfNeeded;
@end

@implementation IFImageCIImage

- (id)initWithCIImage:(CIImage*)theImage;
{
  if (![super init])
    return nil;
  image = [theImage retain];
  isInfinite = CGRectIsInfinite([image extent]);
  cache = nil;
  usages = 0;
  usagesBeforeCache = 2;
  return self;
}

- (void)dealloc;
{
  [cache release];
  cache = nil;
  [image release];
  image = nil;
  [super dealloc];
}

- (void)setUsagesBeforeCacheHint:(unsigned)hint;
{
  if (cache == nil)
    usagesBeforeCache = hint;
}

- (unsigned)usagesBeforeCache;
{
  return usagesBeforeCache;
}

- (CGRect)extent;
{
  return [image extent];
}

- (CIImage*)imageCI;
{
  [self incrementUsagesAndCacheIfNeeded];
  return (cache != nil) ? [cache image] : image;
}

- (CGImageRef)imageCG;
{
  CGRect extent = [image extent];
  size_t width = CGRectGetWidth(extent), height = CGRectGetHeight(extent);
  size_t bitsPerComponent = 8;
  size_t bytesPerRow = width * 4;
  
  CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); // TODO
  CGContextRef cgContext = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, cs, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(cs);
  CIContext* ciContext = [CIContext contextWithCGContext:cgContext options:nil]; // TODO options?
  CGContextRelease(cgContext);
  return [ciContext createCGImage:image fromRect:[image extent]];  
}

- (BOOL)isLocked;
{
  return [self retainCount] > 1 || [image retainCount] > 1 || (cache != nil && [cache retainCount] > 1);
}

- (void)logRetainCounts;
{
  NSLog(@"%@  self=%d  image=%d  cache=%d",self,[self retainCount],[image retainCount],cache == nil ? 0 : [cache retainCount]);
}

@end

@implementation IFImageCIImage (Private)

- (void)incrementUsagesAndCacheIfNeeded;
{
  ++usages;
  if (!isInfinite && cache == nil && usages >= usagesBeforeCache) {
    cache = [[CIImageAccumulator imageAccumulatorWithExtent:[self extent] format:kCIFormatARGB8] retain]; // TODO color space, format
    [cache setImage:image];
  }
}

@end
