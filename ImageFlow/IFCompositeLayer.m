//
//  IFCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCompositeLayer.h"

@implementation IFCompositeLayer

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

- (IFLayer*)displayedImageLayer;
{
  return nil;
}

- (IFLayer*)baseLayer;
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
