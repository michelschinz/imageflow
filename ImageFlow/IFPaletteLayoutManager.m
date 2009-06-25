//
//  IFPaletteLayoutManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 23.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFPaletteLayoutManager.h"
#import "IFLayerSetExplicit.h"
#import "IFLayerSubsetComposites.h"
#import "IFCompositeLayer.h"
#import "IFTree.h"
#import "IFTemplateLayer.h"
#import "IFLayerPredicateSubset.h"
#import "IFLayerSetExplicit.h"

@implementation IFPaletteLayoutManager

+ (id)paletteLayoutManager;
{
  return [[[self alloc] init] autorelease];
}

- (void)dealloc;
{
  OBJC_RELEASE(layoutParameters);
  [super dealloc];
}

@synthesize layoutParameters;
@synthesize delegate;

- (void)layoutSublayersOfLayer:(CALayer*)parentLayer;
{
  IFLayerSubset* layers = [IFLayerPredicateSubset subsetOf:[IFLayerSetExplicit layerSetWithLayers:parentLayer.sublayers] predicate:[NSPredicate predicateWithFormat:@"hidden == NO"]];
  
  const float minGutterX = [IFLayoutParameters gutterWidth];
  const float totalWidth = CGRectGetWidth(parentLayer.bounds);
  const float gutterY = minGutterX;
  
  float y = gutterY;
  unsigned rowStartIndex = 0;
  while (rowStartIndex < [layers count]) {
    unsigned rowEndIndex = rowStartIndex;

    float minRowWidth = minGutterX;
    do {
      minRowWidth += CGRectGetWidth([layers layerAtIndex:rowEndIndex].frame) + minGutterX;
      if (minRowWidth > totalWidth)
        break;
      ++rowEndIndex;
    } while (rowEndIndex < [layers count]);

    float gutterX;
    if (rowEndIndex == rowStartIndex) {
      gutterX = 0;
      rowEndIndex = rowStartIndex + 1;
    } else if (rowEndIndex == [layers count]) {
      gutterX = minGutterX;
    } else {
      float rowWidth = 0.0;
      for (int i = rowStartIndex; i < rowEndIndex; ++i)
        rowWidth += CGRectGetWidth([layers layerAtIndex:i].frame);
      gutterX = (totalWidth - rowWidth - 2.0 * minGutterX) / (rowEndIndex - rowStartIndex - 1);
    }

    float rowHeight = 0.0;
    float x = minGutterX;
    for (int i = rowStartIndex; i < rowEndIndex; ++i) {
      CALayer* layer = [layers layerAtIndex:i];
      layer.position = CGPointMake(x, y);
      x += CGRectGetWidth(layer.frame) + gutterX;
      rowHeight = fmax(rowHeight, CGRectGetHeight(layer.frame));
    }
    y += ceil(rowHeight) + gutterY;
    rowStartIndex = rowEndIndex;
  }
  
  [delegate layoutManager:self didLayoutSublayersOfLayer:parentLayer];
}  

@end
