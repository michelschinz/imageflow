//
//  IFFileExportConstantExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.11.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFFileExportConstantExpression.h"


@implementation IFFileExportConstantExpression

- (id)initWithFileURL:(NSURL*)theFileURL image:(CIImage*)theImage exportArea:(CGRect)theExportArea;
{
  if (![super initWithObject:nil tag:IFExpressionTag_Action])
    return nil;
  fileURL = [theFileURL retain];
  image = [theImage retain];
  exportArea = theExportArea;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(image);
  OBJC_RELEASE(fileURL);
}

- (BOOL)isAction;
{
  return YES;
}

- (void)executeAction;
{
  size_t width = CGRectGetWidth(exportArea), height = CGRectGetHeight(exportArea);
  size_t bitsPerComponent = 8; // TODO: have a parameter for this
  size_t bytesPerRow = width * 4;

  CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); // TODO: use correct color space
  CGContextRef cgContext = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, cs, kCGImageAlphaPremultipliedLast);
  CIContext* ciContext = [CIContext contextWithCGContext:cgContext options:nil]; // TODO: options?
  CGContextRelease(cgContext);
  CGColorSpaceRelease(cs);

  CGImageRef cgImage = [ciContext createCGImage:image fromRect:exportArea];
  CGImageDestinationRef imageDst = CGImageDestinationCreateWithURL((CFURLRef)fileURL, kUTTypeJPEG, 1, NULL); // TODO: get type as parameter
  
  if (imageDst != NULL) {
    CFDictionaryRef emptyDict = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, NULL, NULL);    
    CGImageDestinationAddImage(imageDst, cgImage, emptyDict); // TODO: meta-data (properties)
    CGImageDestinationFinalize(imageDst);
    CFRelease(imageDst);
  }
  CGImageRelease(cgImage);
}

// MARK: Caml representation

- (value)camlRepresentation;
{
  NSAssert(NO, @"not implemented yet"); // TODO: implement
}  

@end
