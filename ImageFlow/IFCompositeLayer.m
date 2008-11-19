//
//  IFCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCompositeLayer.h"

#import "IFLayoutParameters.h"

@implementation IFCompositeLayer

- (id)init;
{
  if (![super init])
    return nil;
  self.anchorPoint = CGPointZero;
  return self;
}

- (BOOL)isNode;
{
  return NO;
}

- (BOOL)isInputConnector;
{
  return NO;
}

- (BOOL)isOutputConnector;
{
  return NO;
}

- (CALayer*)displayedImageLayer;
{
  return nil;
}

- (CALayer<IFBaseLayer>*)baseLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (CALayer*)cursorLayer;
{
  return nil;
}

- (void)setCursorIndicator:(IFLayerCursorIndicator)newIndicator;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  CALayer* cursorLayer = self.cursorLayer;
  switch (newIndicator) {
    case IFLayerCursorIndicatorNone:
      cursorLayer.hidden = YES;
      break;
    case IFLayerCursorIndicatorCursor:
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = layoutParameters.cursorWidth;
      break;
    case IFLayerCursorIndicatorSelection:
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = layoutParameters.selectionWidth;
      break;
  }
}

- (IFLayerCursorIndicator)cursorIndicator;
{
  CALayer* cursorLayer = [self valueForKey:@"cursorLayer"];
  if (cursorLayer.hidden)
    return IFLayerCursorIndicatorNone;
  else if (cursorLayer.borderWidth == [IFLayoutParameters sharedLayoutParameters].cursorWidth)
    return IFLayerCursorIndicatorCursor;
  else
    return IFLayerCursorIndicatorSelection;
}

- (void)setHighlighted:(BOOL)newValue;
{
  CALayer* highlightLayer = [self valueForKey:@"highlightLayer"];
  highlightLayer.hidden = !newValue;
}

- (BOOL)highlighted;
{
  CALayer* highlightLayer = [self valueForKey:@"highlightLayer"];
  return !highlightLayer.hidden;
}

- (IFTreeNode*)node;
{
  return [self.baseLayer node];
}

- (void)setForcedFrameWidth:(float)newForcedFrameWidth;
{
  self.baseLayer.forcedFrameWidth = newForcedFrameWidth;
}

- (float)forcedFrameWidth;
{
  return self.baseLayer.forcedFrameWidth;
}

- (CGSize)preferredFrameSize;
{
  return [self.baseLayer preferredFrameSize];
}

- (void)layoutSublayers;
{
  [super layoutSublayers];
  
  if (!CGSizeEqualToSize([self preferredFrameSize], self.frame.size))
    [self.superlayer setNeedsLayout];
}

@end
