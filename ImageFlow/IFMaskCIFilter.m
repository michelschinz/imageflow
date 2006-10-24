//
//  IFMaskCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFMaskCIFilter.h"


@implementation IFMaskCIFilter

static CIKernel *maskKernel = nil;

- (id)init;
{
  if (maskKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* file = [bundle pathForResource:@"mask" ofType:@"cikernel"];
    NSAssert1([[NSFileManager defaultManager] fileExistsAtPath:file], @"non-existent file %@",file);
    NSString* code = [NSString stringWithContentsOfFile:file];
    maskKernel = [[[CIKernel kernelsWithString:code] objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFMaskCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFMask"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Mask", kCIAttributeFilterDisplayName,
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* imageSampler = [CISampler samplerWithImage:inputImage];
  CISampler* maskSampler = [CISampler samplerWithImage:inputMask];
  return [self apply:maskKernel
           arguments:[NSArray arrayWithObjects:imageSampler,maskSampler,nil]
             options:[NSDictionary dictionaryWithObject:[imageSampler definition] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
