//
//  IFCircleGeneratorCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 09.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFCircleGeneratorCIFilter.h"


@implementation IFCircleGeneratorCIFilter

static CIKernel *circleGeneratorKernel = nil;

- (id)init;
{
  if (circleGeneratorKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"circle" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    circleGeneratorKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  [CIFilter registerFilterName:@"IFCircleGenerator"  
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Circle Generator", kCIAttributeFilterDisplayName,
                 [NSArray arrayWithObjects:
                   kCICategoryGenerator,
                   kCICategoryVideo, 
                   kCICategoryStillImage,
                   nil], kCIAttributeFilterCategories,
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   kCIAttributeDefault, [CIVector vectorWithX:150 Y:150],
                   kCIAttributeTypePosition, kCIAttributeType,
                   nil], @"inputCenter",
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   kCIAttributeDefault, [NSNumber numberWithFloat:100],
                   kCIAttributeTypeDistance, kCIAttributeType,
                   nil], @"inputRadius",
                 [NSDictionary dictionaryWithObjectsAndKeys:
                   kCIAttributeDefault, [CIColor colorWithRed:1 green:1 blue:1],
                   nil], @"inputColor",
                 nil]];
}

- (CIImage*)outputImage;
{
  float cx = [inputCenter X], cy = [inputCenter Y];
  float r = [inputRadius floatValue];
  CIFilterShape* dod = [CIFilterShape shapeWithRect:CGRectMake(cx - r, cy - r, 2.*r, 2.*r)];
  return [self apply:circleGeneratorKernel
           arguments:[NSArray arrayWithObjects:inputCenter,inputRadius,inputColor,nil]
             options:[NSDictionary dictionaryWithObjectsAndKeys:
               dod, kCIApplyOptionDefinition,
               nil]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
