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
#import "IFLayoutParameters.h"
#import "IFTemplateLayer.h"

@implementation IFPaletteLayoutManager

+ (id)paletteLayoutManager;
{
  return [[[self alloc] init] autorelease];
}


@synthesize columnWidth;
@synthesize delegate;

- (void)layoutSublayersOfLayer:(CALayer*)parentLayer;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float minGutterX = layoutParameters.gutterWidth;
  
  const float totalWidth = CGRectGetWidth(parentLayer.bounds);
  const unsigned columns = MAX(1, (unsigned)floor((totalWidth - minGutterX) / (columnWidth + minGutterX)));
  const float gutterX = (totalWidth - ((float)columns * columnWidth)) / (columns + 1);
  const float gutterY = minGutterX;

  unsigned column = 0;
  float x = gutterX, y = 0;
  float rowHeight = 0;
  for (IFTemplateLayer* layer in parentLayer.sublayers) {
    if (layer.hidden)
      continue;

    layer.forcedFrameWidth = columnWidth;
    layer.frame = (CGRect){ CGPointMake(round(x), round(y)), [layer preferredFrameSize] };
    rowHeight = fmax(rowHeight, CGRectGetHeight(layer.frame));
    
    if (++column == columns) {
      x = gutterX;
      y += ceil(rowHeight + gutterY);
      rowHeight = 0;
      column = 0;
    } else
      x += columnWidth + gutterX;
  }
  
  [delegate layoutManager:self didLayoutSublayersOfLayer:parentLayer];
}  

@end
