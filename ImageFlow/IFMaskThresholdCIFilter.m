//
//  IFMaskThresholdCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFMaskThresholdCIFilter.h"


@implementation IFMaskThresholdCIFilter

static CIKernel *thresholdKernel = nil;

- (id)init;
{
  if (thresholdKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"mask-threshold" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    thresholdKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFMaskThresholdCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFMaskThreshold"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Threshold mask", kCIAttributeFilterDisplayName,
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithDouble:0.0], kCIAttributeMin,
                   [NSNumber numberWithDouble:1.0], kCIAttributeMax,
                   [NSNumber numberWithDouble:0.0], kCIAttributeSliderMin,
                   [NSNumber numberWithDouble:0.1], kCIAttributeSliderMax,
                   [NSNumber numberWithDouble:0.5], kCIAttributeDefault,
                   kCIAttributeTypeScalar, kCIAttributeType,
                   nil], @"inputThreshold",
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* inputSampler = [CISampler samplerWithImage:inputImage];
  return [self apply:thresholdKernel
           arguments:[NSArray arrayWithObjects:inputSampler,inputThreshold,nil]
             options:[NSDictionary dictionaryWithObject:[inputSampler definition] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
