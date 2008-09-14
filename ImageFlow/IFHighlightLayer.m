//
//  IFHighlightLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFHighlightLayer.h"


@implementation IFHighlightLayer

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

- (void)drawInCurrentNSGraphicsContext;
{
  [layoutParameters.highlightingColor set];
  [outlinePath setLineWidth:layoutParameters.selectionWidth];
  [outlinePath fill];
  [outlinePath stroke];
}

@end
