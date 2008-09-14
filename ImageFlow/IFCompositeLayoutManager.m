//
//  IFCompositeLayoutManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 17.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCompositeLayoutManager.h"

#import "IFNodeCompositeLayer.h"

@implementation IFCompositeLayoutManager

+ (id)compositeLayoutManagerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters] autorelease];
}

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super init])
    return nil;
  layoutParameters = [theLayoutParameters retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(layoutParameters);
  [super dealloc];
}

void growLayer(CALayer* targetlayer, CALayer* sourceLayer, float delta) {
  targetlayer.bounds = CGRectInset(sourceLayer.bounds, -delta, -delta);
  targetlayer.position = CGPointMake(sourceLayer.position.x - delta, sourceLayer.position.y - delta);
}

- (void)layoutSublayersOfLayer:(CALayer*)layer;
{
  IFNodeCompositeLayer* compositeLayer = (IFNodeCompositeLayer*)layer;
  IFBaseLayer* baseLayer = compositeLayer.baseLayer;
  
  if (!CGSizeEqualToSize([baseLayer preferredFrameSize], compositeLayer.bounds.size))
    [layer.superlayer setNeedsLayout];
  
  IFLayer* displayedImageLayer = compositeLayer.displayedImageLayer;
  if (displayedImageLayer != nil) {
    displayedImageLayer.frame = CGRectInset(baseLayer.frame, -25.0, 0.0);
  }
  
  IFCursorLayer* cursorLayer = compositeLayer.cursorLayer;
  if (cursorLayer != nil) {
    growLayer(cursorLayer, baseLayer, layoutParameters.cursorWidth);
    cursorLayer.outlinePath = baseLayer.outlinePath;
  }
  
  IFHighlightLayer* highlightLayer = compositeLayer.highlightLayer;
  NSAssert(highlightLayer != nil, @"nil highlight layer");
  growLayer(highlightLayer, baseLayer, layoutParameters.selectionWidth);
  highlightLayer.outlinePath = baseLayer.outlinePath;
}

@end
