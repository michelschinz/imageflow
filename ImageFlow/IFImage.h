//
//  IFImage.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  IFImageKindRGBImage,
  IFImageKindMask
} IFImageKind;

@interface IFImage : NSObject {
  IFImageKind kind;
}

+ (id)emptyImage;

+ (id)imageWithCGImage:(CGImageRef)theImage;
+ (id)imageWithCGLayer:(CGLayerRef)theLayer origin:(CGPoint)theOrigin;
+ (id)imageWithCIImage:(CIImage*)theImage;

+ (id)maskWithCIImage:(CIImage*)theMask;

- (id)initWithKind:(IFImageKind)theKind;

- (IFImageKind)kind;

- (BOOL)isLocked;

- (void)setUsagesBeforeCacheHint:(unsigned)cacheCountHint;
- (unsigned)usagesBeforeCache;

- (CGRect)extent;
- (CIImage*)imageCI;
- (CGImageRef)imageCG;

@end
