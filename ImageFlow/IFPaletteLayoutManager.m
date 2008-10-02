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

@implementation IFPaletteLayoutManager

+ (id)paletteLayoutManager;
{
  return [[[self alloc] init] autorelease];
}

@synthesize delegate;

- (void)layoutSublayersOfLayer:(CALayer*)parentLayer;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float columnWidth = layoutParameters.columnWidth;
  const float minGutterX = layoutParameters.gutterWidth;
  
  const float totalWidth = CGRectGetWidth(parentLayer.bounds);
  const unsigned columns = MAX(1, (unsigned)floor((totalWidth - minGutterX) / (columnWidth + minGutterX)));
  const float gutterX = (totalWidth - ((float)columns * columnWidth)) / (columns + 1);
  const float gutterY = minGutterX;
  
  IFLayerSetExplicit* allRows = [IFLayerSetExplicit layerSet];
  IFLayerSetExplicit* currentRow = [IFLayerSetExplicit layerSet];
  float x = gutterX;
  for (CALayer* layer in parentLayer.sublayers) {
    if ([currentRow count] == columns) {
      [allRows translateByX:0 Y:ceil(CGRectGetHeight(currentRow.boundingBox) + gutterY)];
      [allRows addLayersFromGroup:currentRow];
      [currentRow removeAllLayers];
      x = gutterX;
    }
    
    layer.frame = (CGRect){ CGPointMake(round(x), 0), [layer preferredFrameSize] };
    [currentRow addLayer:layer];
    
    x += columnWidth + gutterX;
  }
  [allRows translateByX:0 Y:ceil(CGRectGetHeight(currentRow.boundingBox) + gutterY)];
  
  [delegate layoutManager:self didLayoutSublayersOfLayer:parentLayer];
}  

@end
