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
#import "IFImageFile.h"

@implementation IFImage

static IFImage* emptyImage = nil;

+ (id)emptyImage;
{
  if (emptyImage == nil)
    emptyImage = [[self imageWithCIImage:[CIImage emptyImage]] retain];
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

+ (id)imageWithContentsOfURL:(NSURL*)theURL;
{
  return [[[IFImageFile alloc] initWithFileURL:theURL] autorelease];
}

- (id)initWithKind:(IFImageKind)theKind;
{
  if (![super init])
    return nil;
  kind = theKind;
  return self;
}

@synthesize kind;

- (CGRect)extent;
{
  return self.imageCI.extent;
}

- (CIImage*)imageCI;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSData*)encodedData;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (NSString*)encodingFormat;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)setEncodingFormat:(NSString *)newEncodingFormat;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (NSDictionary*)encodingOptions;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)setEncodingOptions:(NSDictionary *)newEncodingOptions;
{
  [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)isLocked;
{
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (void)setUsagesBeforeCache:(unsigned)cacheCountHint;
{
  // ignore hint by default.
}

- (unsigned)usagesBeforeCache;
{
  return 0;
}

@end
