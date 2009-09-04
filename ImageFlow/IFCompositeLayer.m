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

- (CALayer<IFBaseLayer>*)baseLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
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
  self.highlightLayer.frame = baseFrame;
  [self.superlayer setNeedsLayout];
}

@end
