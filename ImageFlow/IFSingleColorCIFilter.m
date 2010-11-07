//
//  IFSingleColorCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 21.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFSingleColorCIFilter.h"


@implementation IFSingleColorCIFilter

static CIKernel *singleColorKernel = nil;

- (id)init;
{
  if (singleColorKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"single-color" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    singleColorKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFSingleColorCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFSingleColor"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Single Color", kCIAttributeFilterDisplayName,
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   kCIAttributeTypeOpaqueColor, kCIAttributeType,
                   nil], @"inputColor",
                 nil]];
}

- (CIImage*)outputImage;
{
  CISampler* src = [CISampler samplerWithImage:inputImage];
  return [self apply:singleColorKernel,src,inputColor,kCIApplyOptionDefinition,[src definition],nil];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
