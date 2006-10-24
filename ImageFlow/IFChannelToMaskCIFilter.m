//
//  IFChannelToMaskCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFChannelToMaskCIFilter.h"


@implementation IFChannelToMaskCIFilter

static NSDictionary* channelToMaskKernels = nil;

- (id)init;
{
  if (channelToMaskKernels == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* file = [bundle pathForResource:@"channel-to-mask" ofType:@"cikernel"];
    NSAssert1([[NSFileManager defaultManager] fileExistsAtPath:file], @"non-existent file %@",file);
    NSString* code = [NSString stringWithContentsOfFile:file];

    NSMutableDictionary* namedKernels = [NSMutableDictionary dictionary];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    for (int i = 0; i < [kernels count]; ++i)
      [namedKernels setObject:[kernels objectAtIndex:i] forKey:[[kernels objectAtIndex:i] name]];
    channelToMaskKernels = [namedKernels retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFChannelToMaskCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFChannelToMask"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Channel to Mask", kCIAttributeFilterDisplayName,
                 nil]];
}

- (CIImage*)outputImage;
{
  char* channelNames = "rgbal";
  CISampler* imageSampler = [CISampler samplerWithImage:inputImage];
  NSString* kernelName = [NSString stringWithFormat:@"%cToMask",channelNames[[inputChannel intValue]]];
  CIKernel* kernel = [channelToMaskKernels objectForKey:kernelName];
  NSAssert1(kernel != nil, @"no kernel named %@",kernelName);
  return [self apply:kernel
           arguments:[NSArray arrayWithObjects:imageSampler,nil]
             options:[NSDictionary dictionaryWithObject:[imageSampler definition] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
