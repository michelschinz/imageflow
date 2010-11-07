//
//  IFRectangularWindowCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 30.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFRectangularWindowCIFilter.h"


@implementation IFRectangularWindowCIFilter

static CIKernel *rectangularWindowKernel = nil;

- (id)init;
{
  if (rectangularWindowKernel == nil) {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"rectangular-window" ofType:@"cikernel"]];
    NSArray* kernels = [CIKernel kernelsWithString:code];
    rectangularWindowKernel = [[kernels objectAtIndex:0] retain];
  }
  return [super init];
}

+ (void)initialize;
{
  if (self != [IFRectangularWindowCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFRectangularWindow"
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObject:@"Rectangular window" forKey:kCIAttributeFilterDisplayName]];
}

- (CIImage*)outputImage;
{
  CISampler* src = [CISampler samplerWithImage:inputImage];
  float m = [inputCutoutMargin floatValue];
  CIVector* rOut = [CIVector vectorWithX:[inputCutoutRectangle X] - m
                                       Y:[inputCutoutRectangle Y] - m
                                       Z:[inputCutoutRectangle Z] + [inputCutoutRectangle X] + m
                                       W:[inputCutoutRectangle W] + [inputCutoutRectangle Y] + m];
  CIVector* rIn = [CIVector vectorWithX:[inputCutoutRectangle X]
                                      Y:[inputCutoutRectangle Y]
                                      Z:[inputCutoutRectangle Z] + [inputCutoutRectangle X]
                                      W:[inputCutoutRectangle W] + [inputCutoutRectangle Y]];
  return [self apply:rectangularWindowKernel
           arguments:[NSArray arrayWithObjects:src,inputMaskColor,rOut,rIn,nil]
             options:[NSDictionary dictionaryWithObject:[CIFilterShape shapeWithRect:CGRectInfinite] forKey:kCIApplyOptionDefinition]];
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
