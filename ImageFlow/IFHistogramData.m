//
//  IFHistogramData.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFHistogramData.h"

@interface IFHistogramData (Private)
- (float)ratioForIntensity:(float)intensity;
@end

@implementation IFHistogramData

+ (id)histogramDataWithCountsNoCopy:(vImagePixelCount*)theCounts length:(int)theLength total:(vImagePixelCount)theTotal;
{
  return [[[self alloc] initWithCountsNoCopy:theCounts length:theLength total:theTotal] autorelease];
}

- (id)initWithCountsNoCopy:(vImagePixelCount*)theCounts length:(int)theLength total:(vImagePixelCount)theTotal;
{
  if (![super init]) return nil;
  counts = theCounts;
  length = theLength;
  total = theTotal;
  return self;
}

- (void) dealloc {
  if (counts != NULL) {
    free(counts);
    counts = NULL;
  }
  [super dealloc];
}

- (IFHistogramData*)addHistogramData:(IFHistogramData*)other;
{
  NSAssert(length == other->length, @"incompatible length");
  size_t bufferSize = length * sizeof(vImagePixelCount);
  vImagePixelCount* sum = malloc(bufferSize);
  memcpy(sum,other->counts,bufferSize);
  for (int i = 0; i < length; ++i)
    sum[i] += counts[i];
  return [IFHistogramData histogramDataWithCountsNoCopy:sum length:length total:(other->total + total)];
}

- (float)maxRatio;
{
  float max = 0.0;
  for (int i = 0; i < length; ++i)
    max = fmax(max, (float)counts[i] / (float) total);
  return max;
}

- (float)errorForMaxRatio:(float)maxRatio;
{
  float error = 0.0;
  for (int i = 0; i < length; ++i) {
    float ratio = (float)counts[i] / (float) total;
    if (ratio > maxRatio)
      error += 1.0;
  }
  return error / (float)length;
}

- (float)paintedRatioForMaxRatio:(float)maxRatio;
{
  float s = 0.0;
  for (int i = 0; i < length; ++i) {
    float ratio = (float)counts[i] / (float) total;
    s += fmin(ratio, maxRatio);
  }
  return s / ((float)length * maxRatio);  
}

- (NSBezierPath*)pathInRect:(NSRect)rect samples:(int)samples;
{
  float xUnit = NSWidth(rect);
  float yUnit = NSHeight(rect);
  
  float sampleInterval = 1.0 / (float)samples;
  NSBezierPath* path = [NSBezierPath bezierPath];
  [path moveToPoint:NSZeroPoint];
  float x = 0.0;
  for (int i = 0; i < samples; i++, x += sampleInterval) {
    float y = [self ratioForIntensity:x];
    [path lineToPoint:NSMakePoint(x * xUnit, y * yUnit)];
  }
  [path lineToPoint:NSMakePoint(xUnit,0)];
  [path closePath];
  return path;
}

@end

@implementation IFHistogramData (Private)

- (float)ratioForIntensity:(float)intensity;
{
  NSAssert((intensity >= 0.0) && (intensity <= 1.0), @"invalid intensity");
  float x = intensity * (float)length;
  float ratio = (float)counts[(int)floor(x)] / (float)total;
  return ratio;
}

@end
