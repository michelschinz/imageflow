//
//  IFThresholdCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 02.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFThresholdCIFilter.h"

@implementation IFThresholdCIFilter

static CIKernel *thresholdKernel = nil;

- (id)init;
{
  if (thresholdKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"threshold" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    thresholdKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  [CIFilter registerFilterName:@"IFThreshold"  
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Threshold", kCIAttributeFilterDisplayName,
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
  CISampler* src = [CISampler samplerWithImage:inputImage];
  return [self apply:thresholdKernel,src,inputThreshold,kCIApplyOptionDefinition,[src definition],nil];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
