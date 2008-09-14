//
//  IFNodeCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFNodeCompositeLayer.h"
#import "IFGhostNodeLayer.h"
#import "IFCompositeLayoutManager.h"
#import "IFDisplayedImageLayer.h"
#import "IFHighlightLayer.h"

typedef enum {
  IFCompositeSublayerDisplayedImage,
  IFCompositeSublayerBase,
  IFCompositeSublayerCursor,
  IFCompositeSublayerHighlight,
} IFCompositeSublayer;

@implementation IFNodeCompositeLayer

+ (id)layerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initWithNode:theNode layoutParameters:theLayoutParameters] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;

  self.zPosition = 1.0;
  
  [self addSublayer:[IFDisplayedImageLayer displayedImageLayerWithLayoutParameters:theLayoutParameters]];
  [self addSublayer:([theNode isGhost]
                     ? [IFGhostNodeLayer ghostLayerForNode: theNode layoutParameters:theLayoutParameters]
                     : [IFNodeLayer layerForNode:theNode layoutParameters:theLayoutParameters])];
  [self addSublayer:[IFCursorLayer cursorLayerWithLayoutParameters:theLayoutParameters]];
  [self addSublayer:[IFHighlightLayer highlightLayerWithLayoutParameters:theLayoutParameters]];

  // Hide all layers but the base
  self.displayedImageLayer.hidden = YES;
  self.cursorLayer.hidden = YES;
  self.highlightLayer.hidden = YES;

  return self;
}

- (BOOL)isNode;
{
  return YES;
}

- (IFLayer*)displayedImageLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerDisplayedImage];
}

- (IFNodeLayer*)baseLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerBase];
}

- (IFCursorLayer*)cursorLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerCursor];
}

- (IFLayer*)highlightLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerHighlight];
}
  
@end
