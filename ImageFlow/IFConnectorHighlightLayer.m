//
//  IFHighlightLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorHighlightLayer.h"


@implementation IFConnectorHighlightLayer

+ (id)highlightLayerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters] autorelease];
}

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;
  self.needsDisplayOnBoundsChange = YES;
  return self;
}

@synthesize outlinePath;

- (void)drawInContext:(CGContextRef)context;
{
  NSGraphicsContext *nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:nsGraphicsContext];
  
  [layoutParameters.highlightingColor set];
  [outlinePath setLineWidth:layoutParameters.selectionWidth];
  [outlinePath fill];
  [outlinePath stroke];
  
  [NSGraphicsContext restoreGraphicsState];
}

@end
