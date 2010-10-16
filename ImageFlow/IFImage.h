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
+ (id)imageWithContentsOfURL:(NSURL*)theURL;

+ (id)maskWithCIImage:(CIImage*)theMask;

@property(readonly) IFImageKind kind;
@property(readonly) CGRect extent;
@property(readonly) CIImage* imageCI;

@property(readonly) NSData* encodedData;
@property(retain) NSString* encodingFormat;
@property(retain) NSDictionary* encodingOptions;

@property(readonly) BOOL isLocked;
@property unsigned usagesBeforeCache;

// MARK: -
// MARK: PROTECTED

- (id)initWithKind:(IFImageKind)theKind;

@end
