//
//  IFConnectorCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorCompositeLayer.h"

#import "IFConnectorHighlightLayer.h"

typedef enum {
  IFCompositeSublayerBase,
  IFCompositeSublayerHighlight,
} IFCompositeSublayer;

@implementation IFConnectorCompositeLayer

+ (id)layerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  return [[[self alloc] initWithNode:theNode kind:theKind] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  if (![super init])
    return nil;
  
  CALayer* baseLayer = [IFConnectorLayer connectorLayerForNode:theNode kind:theKind];

  CALayer* highlightLayer = [IFConnectorHighlightLayer highlightLayer];
  highlightLayer.frame = baseLayer.frame;
  highlightLayer.hidden = YES;
  highlightLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  [self addSublayer:baseLayer];
  [self addSublayer:highlightLayer];
  
  return self;
}

- (BOOL)isInputConnector;
{
  return ((IFConnectorLayer*)self.baseLayer).kind == IFConnectorKindInput;
}

- (BOOL)isOutputConnector;
{
  return ((IFConnectorLayer*)self.baseLayer).kind == IFConnectorKindOutput;
}

- (CALayer*)baseLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerBase];
}

- (CALayer*)highlightLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerHighlight];
}

- (void)layoutSublayers;
{
  ((IFConnectorHighlightLayer*)self.highlightLayer).outlinePath = ((IFConnectorLayer*)self.baseLayer).outlinePath;
  [super layoutSublayers];
}

@end
