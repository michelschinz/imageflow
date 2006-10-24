//
//  IFSetAlphaCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFSetAlphaCIFilter.h"


@implementation IFSetAlphaCIFilter

static CIKernel *setAlphaKernel = nil;

- (id)init;
{
  if (setAlphaKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"opacity" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    setAlphaKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFSetAlphaCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFSetAlpha"  
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Set alpha", kCIAttributeFilterDisplayName,
                 [NSArray arrayWithObjects:
                   kCICategoryVideo, 
                   kCICategoryStillImage,
                   kCICategoryInterlaced,
                   kCICategoryNonSquarePixels,
                   nil], kCIAttributeFilterCategories,
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithDouble:0.0], kCIAttributeMin,
                   [NSNumber numberWithDouble:1.0], kCIAttributeMax,
                   [NSNumber numberWithDouble:0.0], kCIAttributeSliderMin,
                   [NSNumber numberWithDouble:0.1], kCIAttributeSliderMax,
                   [NSNumber numberWithDouble:1.0], kCIAttributeDefault,
                   [NSNumber numberWithDouble:1.0], kCIAttributeIdentity,
                   kCIAttributeTypeScalar, kCIAttributeType,
                   nil], @"inputAlpha",
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* src = [CISampler samplerWithImage:inputImage];
  return [self apply:setAlphaKernel,src,inputAlpha,kCIApplyOptionDefinition,[src definition],nil];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
