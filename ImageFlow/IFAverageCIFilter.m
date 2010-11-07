//
//  IFAverageCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.06.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import "IFAverageCIFilter.h"

static CIKernel* kernelForArity(unsigned arity);

@implementation IFAverageCIFilter

+ (void)initialize;
{
  if (self != [IFAverageCIFilter class])
    return; // avoid repeated initialisation

  [CIFilter registerFilterName:@"IFAverage" constructor:self classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                              @"Average images", kCIAttributeFilterDisplayName,
                                                                              nil]];
}

+ (CIFilter*)filterWithName:(NSString*)theName;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(inputImages);
  [super dealloc];
}

- (NSUInteger)countOfInputImages;
{
  return [inputImages count];
}

- (CIImage*)objectInInputImagesAtIndex:(NSUInteger)index;
{
  return [inputImages objectAtIndex:index];
}

- (void)insertObject:(CIImage*)image inInputImagesAtIndex:(NSUInteger)index;
{
  [inputImages insertObject:image atIndex:index];
}

- (void)removeObjectFromInputImagesAtIndex:(NSUInteger)index;
{
  [inputImages removeObjectAtIndex:index];
}

- (CIImage*)outputImage;
{
  NSMutableArray* inputSamplers = [NSMutableArray arrayWithCapacity:[inputImages count]];
  CIFilterShape* definition = [CIFilterShape shapeWithRect:CGRectNull];
  for (CIImage* image in inputImages) {
    CISampler* sampler = [CISampler samplerWithImage:image];
    [inputSamplers addObject:sampler];
    definition = [definition unionWith:[sampler definition]];
  }

  return [self apply:kernelForArity([inputImages count]) arguments:inputSamplers options:[NSDictionary dictionaryWithObject:definition forKey:kCIApplyOptionDefinition]];
}

@end

// Kernel example (arity 2):
// kernel vec4 average2(sampler i1, sampler i2)
// {
//   vec4 p1 = sample(i1, samplerCoord(i1));
//   vec4 p2 = sample(i2, samplerCoord(i2));
//   return (p1 + p2) / 2.0;
// }

static CIKernel* kernelForArity(unsigned arity)
{
  NSMutableString* kernelStr = [NSMutableString string];

  [kernelStr appendFormat:@"kernel vec4 average%d(", arity];
  for (unsigned i = 1; i <= arity; ++i)
    [kernelStr appendFormat:@"%ssampler i%d", (i > 1 ? ", " : ""), i];
  [kernelStr appendString:@")\n{\n"];
  for (unsigned i = 1; i <= arity; ++i)
    [kernelStr appendFormat:@"  vec4 p%d = sample(i%d, samplerCoord(i%d));\n", i, i, i];
  [kernelStr appendString:@"  return ("];
  for (unsigned i = 1; i <= arity; ++i)
    [kernelStr appendFormat:@"%sp%d", (i > 1 ? " + " : ""), i];
  [kernelStr appendFormat:@") / %d.0;\n}", arity];

  return [[CIKernel kernelsWithString:kernelStr] objectAtIndex:0];
}

