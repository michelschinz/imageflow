//
//  IFEmptyCIFilter.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFEmptyCIFilter.h"


@implementation IFEmptyCIFilter

static CIImage* emptyImage = nil;

+ (void)initialize;
{
  [CIFilter registerFilterName:@"IFEmpty"  
                   constructor:self
               classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                 @"Empty", kCIAttributeFilterDisplayName,
                 nil]];
}

- (id)init;
{
  if (emptyImage == nil)
    emptyImage = [[[CIImageAccumulator imageAccumulatorWithExtent:CGRectZero format:kCIFormatARGB8] image] retain];
  return [super init];
}

- (CIImage*)outputImage;
{
  return emptyImage;
}

+ (CIFilter*)filterWithName:(NSString*)name;
{
  return [[[self alloc] init] autorelease];
}

@end
