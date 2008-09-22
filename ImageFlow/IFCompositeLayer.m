//
//  IFCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCompositeLayer.h"

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

- (CALayer*)baseLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (CALayer*)cursorLayer;
{
  return nil;
}

- (CALayer*)highlightLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFTreeNode*)node;
{
  return [self.baseLayer valueForKey:@"node"]; // HACK (slightly hackish)
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
