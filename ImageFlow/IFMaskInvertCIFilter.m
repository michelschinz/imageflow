//
//  IFMaskInvertCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFMaskInvertCIFilter.h"


@implementation IFMaskInvertCIFilter

static CIKernel *maskInvertKernel = nil;

- (id)init;
{
  if (maskInvertKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"mask-invert" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    maskInvertKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  [CIFilter registerFilterName:@"IFMaskInvert"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Invert mask", kCIAttributeFilterDisplayName,
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* inputSampler = [CISampler samplerWithImage:inputImage];
  return [self apply:maskInvertKernel
           arguments:[NSArray arrayWithObject:inputSampler]
             options:[NSDictionary dictionaryWithObject:[inputSampler definition] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
