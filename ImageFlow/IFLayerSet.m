//
//  IFLayerSet.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerSet.h"


@implementation IFLayerSet

- (CALayer*)firstLayer;
{
  for (CALayer* layer in self)
    return layer;
  return nil;
}

- (CALayer*)lastLayer;
{
  CALayer* last = nil;
  for (CALayer* layer in self)
    last = layer;
  return last;
}

- (CALayer*)layerAtIndex:(int)index;
{
  for (CALayer* layer in self) {
    if (index-- == 0)
      return layer;
  }
  return nil;
}

- (NSArray*)toArray;
{
  NSMutableArray* array = [NSMutableArray array];
  for (CALayer* layer in self)
    [array addObject:layer];
  return array;
}

- (unsigned)count;
{
  unsigned count = 0;
  for (CALayer* layer in self)
    ++count;
  return count;
}

- (CGRect)boundingBox;
{
  CGRect bbox = CGRectNull;
  for (CALayer* layer in self)
    bbox = CGRectIsNull(bbox) ? layer.frame : CGRectUnion(bbox, layer.frame);
  return bbox;
}

- (void)translateByX:(float)dx Y:(float)dy;
{
  for (CALayer* layer in self) {
    CGPoint currPos = layer.position;
    layer.position = CGPointMake(currPos.x + dx, currPos.y + dy);
  }
}

- (CALayer*)hitTest:(CGPoint)point;
{
  for (CALayer* layer in self) {
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
