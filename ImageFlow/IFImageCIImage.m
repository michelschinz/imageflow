//
//  IFImageCIImage.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageCIImage.h"

@interface IFImageCIImage ()
- (void)incrementUsagesAndCacheIfNeeded;
@end

@implementation IFImageCIImage

- (id)initWithCIImage:(CIImage*)theImage kind:(IFImageKind)theKind;
{
  if (![super initWithKind:theKind])
    return nil;
  imageCI = [theImage retain];
  isInfinite = CGRectIsInfinite([imageCI extent]);
  cache = nil;
  usages = 0;
  usagesBeforeCache = 2;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(cache);
  OBJC_RELEASE(imageCI);
  [super dealloc];
}

@synthesize usagesBeforeCache;
- (void)setUsagesBeforeCache:(unsigned)hint;
{
  if (cache == nil)
    usagesBeforeCache = hint;
}

- (CGRect)extent;
{
  return [imageCI extent];
}

- (CIImage*)imageCI;
{
  [self incrementUsagesAndCacheIfNeeded];
  return (cache != nil) ? [cache image] : imageCI;
}

- (BOOL)isLocked;
{
  return [self retainCount] > 1 || [imageCI retainCount] > 1 || (cache != nil && [cache retainCount] > 1);
}

// MARK: -
// MARK: PRIVATE

- (void)incrementUsagesAndCacheIfNeeded;
{
  ++usages;
  if (!isInfinite && cache == nil && usages >= usagesBeforeCache) {
    cache = [[CIImageAccumulator imageAccumulatorWithExtent:[self extent] format:kCIFormatARGB8] retain]; // TODO color space, format
    [cache setImage:imageCI];
  }
}

@end
