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

+ (id)imageWithCGImage:(CGImageRef)theImage;
+ (id)imageWithCIImage:(CIImage*)theImage;

- (BOOL)isLocked;

- (void)setUsagesBeforeCacheHint:(unsigned)cacheCountHint;
- (unsigned)usagesBeforeCache;

- (CGRect)extent;
- (CIImage*)imageCI;
- (CGImageRef)imageCG;

@end
