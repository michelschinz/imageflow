//
//  IFMaskToImageCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFMaskToImageCIFilter.h"


@implementation IFMaskToImageCIFilter

static CIKernel* maskToImageKernel = nil;

- (id)init;
{
  if (maskToImageKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* file = [bundle pathForResource:@"mask-to-image" ofType:@"cikernel"];
    NSAssert1([[NSFileManager defaultManager] fileExistsAtPath:file], @"non-existent file %@",file);
    NSString* code = [NSString stringWithContentsOfFile:file];
    
    maskToImageKernel = [[[CIKernel kernelsWithString:code] objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFMaskToImageCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFMaskToImage"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Mask to Image", kCIAttributeFilterDisplayName,
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* maskSampler = [CISampler samplerWithImage:inputMask];
  return [self apply:maskToImageKernel
           arguments:[NSArray arrayWithObjects:maskSampler,nil]
             options:[NSDictionary dictionaryWithObject:[CIFilterShape shapeWithRect:CGRectInfinite] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
