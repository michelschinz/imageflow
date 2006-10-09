//
//  IFHistogramConstantExpression.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFHistogramConstantExpression.h"

@implementation IFHistogramConstantExpression

+ (id)histogramWithImageExpression:(IFImageConstantExpression*)theImageExpression colorSpace:(CGColorSpaceRef)theColorSpace;
{
  return [[[self alloc] initWithImageExpression:theImageExpression colorSpace:theColorSpace] autorelease];
}

- (id)initWithImageExpression:(IFImageConstantExpression*)theImageExpression colorSpace:(CGColorSpaceRef)theColorSpace;
{
  if (![super init])
    return nil;
  imageExpression = [theImageExpression retain];
  colorSpace = CGColorSpaceRetain(theColorSpace);
  return self;
}

- (void) dealloc {
  CGColorSpaceRelease(colorSpace);
  colorSpace = NULL;
  [imageExpression release];
  imageExpression = nil;
  [super dealloc];
}

- (NSArray*)histogramValue;
{
  if (object == nil)
    object = [[self force] retain];
  return (NSArray*)object;
}

- (NSArray*)force;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
