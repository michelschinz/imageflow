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
  CALayer* cursorLayer = self.cursorLayer;
  switch (newIndicator) {
    case IFLayerCursorIndicatorNone:
      cursorLayer.hidden = YES;
      break;
    case IFLayerCursorIndicatorCursor:
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = [IFLayoutParameters cursorWidth];
      break;
    case IFLayerCursorIndicatorSelection:
      cursorLayer.hidden = NO;
      cursorLayer.borderWidth = [IFLayoutParameters selectionWidth];
      break;
  }
}

- (IFLayerCursorIndicator)cursorIndicator;
{
  CALayer* cursorLayer = self.cursorLayer;
  if (cursorLayer.hidden)
    return IFLayerCursorIndicatorNone;
  else if (cursorLayer.borderWidth == [IFLayoutParameters cursorWidth])
    return IFLayerCursorIndicatorCursor;
  else
    return IFLayerCursorIndicatorSelection;
}

- (CALayer*)highlightLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)setHighlighted:(BOOL)newValue;
{
  self.highlightLayer.hidden = !newValue;
}

- (BOOL)highlighted;
{
  return !self.highlightLayer.hidden;
}

- (IFTreeNode*)node;
{
  return self.baseLayer.node;
}

- (void)layoutSublayers;
{
  CGRect baseFrame = self.baseLayer.frame;
  self.frame = baseFrame;
  if (self.displayedImageLayer != nil)
    self.displayedImageLayer.frame = CGRectInset(baseFrame, -25, 0);
  if (self.cursorLayer != nil)
    self.cursorLayer.frame = baseFrame;
  self.highlightLayer.frame = baseFrame;
  [self.superlayer setNeedsLayout];
}

@end
