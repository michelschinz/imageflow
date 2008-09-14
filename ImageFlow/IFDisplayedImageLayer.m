//
//  IFDisplayedImageLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFDisplayedImageLayer.h"


@implementation IFDisplayedImageLayer

static NSImage* lockLockedImage;
static NSImage* lockUnlockedImage;

+ (void)initialize;
{
  if (self != [IFDisplayedImageLayer class])
    return; // avoid repeated initialisation
  lockLockedImage = [NSImage imageNamed:NSImageNameLockLockedTemplate];
  lockUnlockedImage = [NSImage imageNamed:NSImageNameLockUnlockedTemplate];
}


+ (id)displayedImageLayerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters] autorelease];
}

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;
  self.backgroundColor = CGColorCreateGenericGray(0.75, 1.0);
  
  // Setup a fake frame to make the placement of sublayers possible
  self.frame = CGRectMake(0, 0, 100, 100);
  
  NSSize lockSize = [lockLockedImage size];
  float lockMaxSize = fmax(lockSize.width, lockSize.height) + 4.0;
  
  // Create sublayers, whose contents is provided by this layer (which is the sublayers' delegate)
  lockLayer = [CALayer layer];
  lockLayer.frame = CGRectMake(3, 87, lockMaxSize, lockMaxSize);
  lockLayer.autoresizingMask = kCALayerMaxXMargin | kCALayerMinYMargin;
  lockLayer.delegate = self;
  [self addSublayer:lockLayer];
  [lockLayer setNeedsDisplay];
  
  return self;
}

- (void)drawInContext:(CGContextRef)context;
{
  // nothing to do (the background color is enough)
}

// delegate methods

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;
{
  NSAssert(layer == lockLayer, @"unexpected layer");
  
  NSGraphicsContext *nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:nsGraphicsContext];
  if (layer == lockLayer) {
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.5] setFill];
    [[NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect(layer.bounds)] fill];
    [lockLockedImage compositeToPoint:NSMakePoint(4, 4) operation:NSCompositeSourceOver];
  }
  [NSGraphicsContext restoreGraphicsState];
}

@end
