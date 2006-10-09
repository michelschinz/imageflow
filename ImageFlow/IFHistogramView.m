//
//  IFHistogramView.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFHistogramView.h"
#import "IFHistogramData.h"

@implementation IFHistogramView

- (id)initWithFrame:(NSRect)frame {
  if (![super initWithFrame:frame])
    return nil;
  histogramsRGB = nil;
  displayedChannelIndex = 3;
  useColor = YES;
  return self;
}

- (void) dealloc;
{
  [self setHistogramsRGB:nil];
  [super dealloc];
}

- (void)setHistogramsRGB:(NSArray*)newHistogramsRGB;
{
  if (newHistogramsRGB == histogramsRGB)
    return;
  [histogramsRGB release];
  histogramsRGB = [newHistogramsRGB retain];
  
  [self setNeedsDisplay:YES];
}

- (NSArray*)channelNames;
{
  return [NSArray arrayWithObjects:@"Red",@"Green",@"Blue",@"RGB",nil];
}

- (int)displayedChannelIndex;
{
  return displayedChannelIndex;
}

- (void)setDisplayedChannelIndex:(int)newDisplayedChannelIndex;
{
  if (newDisplayedChannelIndex == displayedChannelIndex)
    return;
  displayedChannelIndex = newDisplayedChannelIndex;
  [self setNeedsDisplay:YES];
}

- (BOOL)useColor;
{
  return useColor;
}

- (void)setUseColor:(BOOL)newUseColor;
{
  if (newUseColor == useColor)
    return;
  useColor = newUseColor;
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect;
{
  NSRect bounds = [self bounds];
  
  [(useColor ? [NSColor blackColor] : [NSColor whiteColor]) set];
  [NSBezierPath fillRect:bounds];
  
  int samples = NSWidth(bounds);
  if (histogramsRGB == nil || [histogramsRGB count] < 3)
    return;

  NSMutableArray* colors = [NSMutableArray array];
  NSMutableArray* histograms = [NSMutableArray array];
  
  if (displayedChannelIndex == 0 || displayedChannelIndex == 3) {
    [colors addObject:[NSColor redColor]];
    [histograms addObject:[histogramsRGB objectAtIndex:0]];
  }
  if (displayedChannelIndex == 1 || displayedChannelIndex == 3) {
    [colors addObject:[NSColor greenColor]];
    [histograms addObject:[histogramsRGB objectAtIndex:1]];
  }
  if (displayedChannelIndex == 2 || displayedChannelIndex == 3) {
    [colors addObject:[NSColor blueColor]];
    [histograms addObject:[histogramsRGB objectAtIndex:2]];
  }

  NSEnumerator* histogramsEnum;
  IFHistogramData* histogram;

  if (!useColor) {
    histogramsEnum = [histograms objectEnumerator];
    IFHistogramData* summedData = [histogramsEnum nextObject];
    while (histogram = [histogramsEnum nextObject])
      summedData = [summedData addHistogramData:histogram];
    colors = [NSArray arrayWithObject:[NSColor blackColor]];
    histograms = [NSArray arrayWithObject:summedData];
  }
  
  const int histogramsCount = [histograms count];
  
  float maxRatio = 0.0;
  histogramsEnum = [histograms objectEnumerator];
  while (histogram = [histogramsEnum nextObject])
    maxRatio = fmax(maxRatio, [histogram maxRatio]);
  const float maxError = 1.0 / 100.0;
  const float desiredPaintedRatio = 25.0 / 100.0;
  for (;;) {
    float totalPaintedRatio = 0;
    histogramsEnum = [histograms objectEnumerator];
    while (histogram = [histogramsEnum nextObject])
      totalPaintedRatio += [histogram paintedRatioForMaxRatio:maxRatio];
    if (totalPaintedRatio / (float)histogramsCount >= desiredPaintedRatio)
      break;
    float nextMaxRatio = maxRatio - 0.02;
    float totalError = 0;
    histogramsEnum = [histograms objectEnumerator];
    while (histogram = [histogramsEnum nextObject])
      totalError += [histogram errorForMaxRatio:nextMaxRatio];
    if (totalError / (float)histogramsCount >= maxError || nextMaxRatio <= 0.0)
      break;
    maxRatio = nextMaxRatio;
  }
  
  NSAffineTransform* scaling = [NSAffineTransform transform];
  [scaling scaleXBy:1.0 yBy:(1.0/maxRatio)];

  [NSGraphicsContext saveGraphicsState];
  if (useColor)
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositePlusLighter];
  for (int i = 0; i < [histograms count]; ++i) {
    IFHistogramData* hist = [histograms objectAtIndex:i];
    NSBezierPath* path = [hist pathInRect:bounds samples:samples];
    [path transformUsingAffineTransform:scaling];
    [(NSColor*)[colors objectAtIndex:i] set];
    [path fill];
  }
  [NSGraphicsContext restoreGraphicsState];
}

@end
