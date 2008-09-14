//
//  IFCursorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCursorLayer.h"

@implementation IFCursorLayer

+ (id)cursorLayerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
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

- (void)drawInCurrentNSGraphicsContext;
{
  [layoutParameters.cursorColor set];
  [outlinePath setLineWidth:(isCursor ? layoutParameters.cursorWidth : layoutParameters.selectionWidth)];
  [outlinePath stroke];
}

@synthesize outlinePath;
@synthesize isCursor;

- (void)setIsCursor:(BOOL)newIsCursor;
{
  if (newIsCursor == isCursor)
    return;
  isCursor = newIsCursor;
  [self setNeedsDisplay];
}

@end
