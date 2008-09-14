//
//  IFLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayer.h"

@implementation IFLayer

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super init])
    return nil;
  layoutParameters = [theLayoutParameters retain];
  self.anchorPoint = CGPointZero;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(layoutParameters);
  [super dealloc];
}

- (void)drawInContext:(CGContextRef)context;
{
  NSGraphicsContext *nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:nsGraphicsContext];
  [self drawInCurrentNSGraphicsContext];
  [NSGraphicsContext restoreGraphicsState];
}

- (void)drawInCurrentNSGraphicsContext;
{
  [self doesNotRecognizeSelector:_cmd];
}

@end
