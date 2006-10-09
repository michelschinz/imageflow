//
//  IFMaskCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFMaskCIFilter.h"


@implementation IFMaskCIFilter

static NSArray *maskKernels = nil;

- (id)init;
{
  if (maskKernels == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* file = [bundle pathForResource:@"mask" ofType:@"cikernel"];
    NSAssert1([[NSFileManager defaultManager] fileExistsAtPath:file], @"non-existent file %@",file);
    NSString* code = [NSString stringWithContentsOfFile:file];
    maskKernels = [[CIKernel kernelsWithString:code] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  [CIFilter registerFilterName:@"IFMask"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Mask", kCIAttributeFilterDisplayName,
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithInt:0], kCIAttributeMin,
                   [NSNumber numberWithInt:4], kCIAttributeMax,
                   [NSNumber numberWithInt:0], kCIAttributeSliderMin,
                   [NSNumber numberWithInt:4], kCIAttributeSliderMax,
                   [NSNumber numberWithInt:0], kCIAttributeDefault,
                   kCIAttributeTypeScalar, kCIAttributeType,
                   nil], @"inputMaskChannel",
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithInt:0], kCIAttributeMin,
                   [NSNumber numberWithInt:1], kCIAttributeMax,
                   [NSNumber numberWithInt:0], kCIAttributeSliderMin,
                   [NSNumber numberWithInt:1], kCIAttributeSliderMax,
                   [NSNumber numberWithInt:0], kCIAttributeDefault,
                   kCIAttributeTypeScalar, kCIAttributeType,
                   nil], @"inputMode",
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* imageSampler = [CISampler samplerWithImage:inputImage];
  CISampler* maskSampler = [CISampler samplerWithImage:inputMaskImage];
  // TODO provide more precise definition
  int mode = [inputMode intValue];
  CIKernel* kernel = [maskKernels objectAtIndex:(2 * [inputMaskChannel intValue] + mode)];
  return (mode == 0)
    ? [self apply:kernel,imageSampler,maskSampler,kCIApplyOptionDefinition,[[imageSampler definition] intersectWith:[maskSampler definition]],nil]
    : [self apply:kernel,imageSampler,maskSampler,[CIColor colorWithRed:1 green:0 blue:0 alpha:0.8],kCIApplyOptionDefinition,[[imageSampler definition] intersectWith:[maskSampler definition]],nil];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
