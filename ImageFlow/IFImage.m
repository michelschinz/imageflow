//
//  IFImage.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImage.h"
#import "IFImageCGImage.h"
#import "IFImageCIImage.h"

@implementation IFImage

+ (id)imageWithCGImage:(CGImageRef)theImage;
{
  return [[[IFImageCGImage alloc] initWithCGImage:theImage] autorelease];
}

+ (id)imageWithCIImage:(CIImage*)theImage;
{
  return [[[IFImageCIImage alloc] initWithCIImage:theImage] autorelease];
}

- (BOOL)isLocked;
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (void)setUsagesBeforeCacheHint:(unsigned)cacheCountHint;
{
  // ignore hint by default.
}

- (unsigned)usagesBeforeCache;
{
  return 0;
}

- (CGRect)extent;
{
  [self doesNotRecognizeSelector:_cmd];
  return CGRectZero;
}

- (CIImage*)imageCI;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (CGImageRef)imageCG;
{
  [self doesNotRecognizeSelector:_cmd];
  return NULL;
}

@end
