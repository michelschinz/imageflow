//
//  IFHistogramConstantExpressionCI.m
//  ImageFlow
//
//  Created by Michel Schinz on 31.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageConstantExpression.h"
#import "IFHistogramConstantExpressionCI.h"

#import <QuartzCore/CIContext.h>

@implementation IFHistogramConstantExpressionCI

- (NSArray*)force;
{
  CIImage* image = [(IFImageConstantExpression*)imageExpression imageValueCI];
  CGRect extent = CGRectIntegral([image extent]);  
  float width = CGRectGetWidth(extent), height = CGRectGetHeight(extent);

  // Draw image in bitmap context
  const size_t bitsPerComponent = 8;
  size_t bytesPerRow = ((int)width * bitsPerComponent + 0xF) & ~0xF;
  void* bitmapData = malloc(bytesPerRow * height);
  NSAssert(bitmapData != NULL, @"couldn't allocate bitmap data");
  // TODO premultiply, or not?
  CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,width,height,bitsPerComponent,bytesPerRow,colorSpace,kCGImageAlphaPremultipliedFirst);
  NSAssert(bitmapContext != NULL, @"couldn't create CG context");
  CIContext* ciContext = [CIContext contextWithCGContext:bitmapContext
                                                 options:[NSDictionary dictionaryWithObject:(id)colorSpace forKey:kCIContextWorkingColorSpace]];
  [ciContext drawImage:image atPoint:CGPointZero fromRect:extent];
  CGContextRelease(bitmapContext);
  
  // Compute histogram
  vImage_Buffer vImage;
  vImagePixelCount *histograms[4];
  const int histogramBytes = 256 * sizeof(vImagePixelCount);
  for (int i = 0; i < 4; ++i) {
    histograms[i] = malloc(histogramBytes);
    NSAssert(histograms[i] != NULL, @"couldn't allocate histogram");
  }
  vImage.data = bitmapData;
  vImage.height = height;
  vImage.width = width;
  vImage.rowBytes = bytesPerRow;
  vImageHistogramCalculation_ARGB8888(&vImage, histograms, 0);
  vImagePixelCount totalPixels = width * height;
 
  free(histograms[0]);
  return [NSArray arrayWithObjects:
    [IFHistogramData histogramDataWithCountsNoCopy:histograms[1] length:256 total:totalPixels],
    [IFHistogramData histogramDataWithCountsNoCopy:histograms[2] length:256 total:totalPixels],
    [IFHistogramData histogramDataWithCountsNoCopy:histograms[3] length:256 total:totalPixels],
    nil];
}

@end
