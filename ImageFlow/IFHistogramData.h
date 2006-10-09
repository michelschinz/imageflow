//
//  IFHistogramData.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFHistogramData : NSObject {
  vImagePixelCount* counts;
  int length;
  vImagePixelCount total;
}

+ (id)histogramDataWithCountsNoCopy:(vImagePixelCount*)theCounts length:(int)theLength total:(vImagePixelCount)theTotal;
- (id)initWithCountsNoCopy:(vImagePixelCount*)theCounts length:(int)theLength total:(vImagePixelCount)theTotal;

- (IFHistogramData*)addHistogramData:(IFHistogramData*)other;

- (float)maxRatio;
- (float)errorForMaxRatio:(float)maxRatio;
- (float)paintedRatioForMaxRatio:(float)maxRatio;

- (NSBezierPath*)pathInRect:(NSRect)rect samples:(int)samples;

@end
