//
//  IFMaskOverlayCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFMaskOverlayCIFilter.h"

@implementation IFMaskOverlayCIFilter

static CIKernel *maskOverlayKernel = nil;

- (id)init;
{
  if (maskOverlayKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* file = [bundle pathForResource:@"mask-overlay" ofType:@"cikernel"];
    NSAssert1([[NSFileManager defaultManager] fileExistsAtPath:file], @"non-existent file %@",file);
    NSString* code = [NSString stringWithContentsOfFile:file];
    maskOverlayKernel = [[[CIKernel kernelsWithString:code] objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFMaskOverlayCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFMaskOverlay"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Mask overlay", kCIAttributeFilterDisplayName,
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* imageSampler = [CISampler samplerWithImage:inputImage];
  CISampler* maskSampler = [CISampler samplerWithImage:inputMask];
  return [self apply:maskOverlayKernel
           arguments:[NSArray arrayWithObjects:imageSampler,maskSampler,inputColor,nil]
             options:[NSDictionary dictionaryWithObject:[imageSampler definition] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
