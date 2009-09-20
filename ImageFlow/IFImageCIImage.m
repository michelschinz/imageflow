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

- (id)initWithCIImage:(CIImage*)theImage kind:(IFImageKind)theKind;
{
  if (![super initWithKind:theKind])
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
  OBJC_RELEASE(cache);
  OBJC_RELEASE(image);
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
