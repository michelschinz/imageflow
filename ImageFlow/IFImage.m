//
//  IFImage.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImage.h"
#import "IFImageCGImage.h"
#import "IFImageCGLayer.h"
#import "IFImageCIImage.h"

@implementation IFImage

static IFImage* emptyImage = nil;

+ (id)emptyImage;
{
  if (emptyImage == nil) {
    CIFilter* ccFilter = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:
      @"inputColor", [CIColor colorWithRed:0 green:0 blue:0 alpha:0],
      nil];
    emptyImage = [[self imageWithCIImage:[ccFilter valueForKey:@"outputImage"]] retain];
  }
  return emptyImage;
}

+ (id)imageWithCGImage:(CGImageRef)theImage;
{
  return [[[IFImageCGImage alloc] initWithCGImage:theImage kind:IFImageKindRGBImage] autorelease];
}

+ (id)imageWithCGLayer:(CGLayerRef)theLayer origin:(CGPoint)theOrigin;
{
  return [[[IFImageCGLayer alloc] initWithCGLayer:theLayer kind:IFImageKindRGBImage origin:theOrigin] autorelease];
}

+ (id)imageWithCIImage:(CIImage*)theImage;
{
  return [[[IFImageCIImage alloc] initWithCIImage:theImage kind:IFImageKindRGBImage] autorelease];
}

+ (id)maskWithCIImage:(CIImage*)theMask;
{
  return [[[IFImageCIImage alloc] initWithCIImage:theMask kind:IFImageKindMask] autorelease];
}

- (id)initWithKind:(IFImageKind)theKind;
{
  if (![super init])
    return nil;
  kind = theKind;
  return self;
}

- (IFImageKind)kind;
{
  return kind;
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

@end
