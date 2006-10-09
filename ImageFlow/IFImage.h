//
//  IFImage.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFImage : NSObject {
}

+ (id)emptyImage;

+ (id)imageWithCGImage:(CGImageRef)theImage;
+ (id)imageWithCGLayer:(CGLayerRef)theLayer origin:(CGPoint)theOrigin;
+ (id)imageWithCIImage:(CIImage*)theImage;

- (BOOL)isLocked;

- (void)setUsagesBeforeCacheHint:(unsigned)cacheCountHint;
- (unsigned)usagesBeforeCache;

- (CGRect)extent;
- (CIImage*)imageCI;
- (CGImageRef)imageCG;

@end
