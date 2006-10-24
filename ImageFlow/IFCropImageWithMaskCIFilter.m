//
//  IFCropImageWithMaskCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFCropImageWithMaskCIFilter.h"


@implementation IFCropImageWithMaskCIFilter

static CIKernel *cropImagePlusMaskKernel = nil;

- (id)init;
{
  if (cropImagePlusMaskKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"crop-overlay" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    cropImagePlusMaskKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFCropImageWithMaskCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFCropOverlay"  
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Crop overlay", kCIAttributeFilterDisplayName,
                 [NSArray arrayWithObjects:
                   kCICategoryVideo, 
                   kCICategoryStillImage,
                   kCICategoryInterlaced,
                   kCICategoryNonSquarePixels,
                   nil], kCIAttributeFilterCategories,
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   kCIAttributeTypeRectangle, kCIAttributeType,
                   nil], @"inputRectangle",
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* src = [CISampler samplerWithImage:inputImage];
  return [self apply:cropImagePlusMaskKernel,src,inputRectangle,kCIApplyOptionDefinition,[src definition],nil];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}


@end
