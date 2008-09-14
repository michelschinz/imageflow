//
//  IFCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCompositeLayer.h"

#import "IFCompositeLayoutManager.h"

@implementation IFCompositeLayer

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;
  self.layoutManager = [IFCompositeLayoutManager compositeLayoutManagerWithLayoutParameters:theLayoutParameters];
  return self;
}

- (CGSize)preferredFrameSize;
{
  return [self.baseLayer preferredFrameSize];
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

- (IFLayer*)displayedImageLayer;
{
  return nil;
}

- (IFBaseLayer*)baseLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFCursorLayer*)cursorLayer;
{
  return nil;
}

- (IFHighlightLayer*)highlightLayer;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (IFTreeNode*)node;
{
  return self.baseLayer.node;
}

@end
