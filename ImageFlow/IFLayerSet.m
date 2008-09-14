//
//  IFLayerSet.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerSet.h"


@implementation IFLayerSet

- (IFLayer*)firstLayer;
{
  for (IFLayer* layer in self)
    return layer;
  return nil;
}

- (IFLayer*)lastLayer;
{
  IFLayer* last = nil;
  for (IFLayer* layer in self)
    last = layer;
  return last;
}

- (IFLayer*)layerAtIndex:(int)index;
{
  for (IFLayer* layer in self) {
    if (index-- == 0)
      return layer;
  }
  return nil;
}

- (CGRect)boundingBox;
{
  CGRect bbox = CGRectNull;
  for (IFLayer* layer in self)
    bbox = CGRectIsNull(bbox) ? layer.frame : CGRectUnion(bbox, layer.frame);
  return bbox;
}

- (void)translateByX:(float)dx Y:(float)dy;
{
  for (IFLayer* layer in self) {
    CGPoint currPos = layer.position;
    layer.position = CGPointMake(currPos.x + dx, currPos.y + dy);
  }
}

- (IFLayer*)hitTest:(CGPoint)point;
{
  for (IFLayer* layer in self) {
    if ([layer hitTest:point])
      return layer;
  }
  return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len;
{
  [self doesNotRecognizeSelector:_cmd];
  return 0;
}

@end
