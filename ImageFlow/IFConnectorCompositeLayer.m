//
//  IFConnectorCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorCompositeLayer.h"

#import "IFConnectorHighlightLayer.h"
#import "IFInputConnectorLayer.h"
#import "IFOutputConnectorLayer.h"

typedef enum {
  IFCompositeSublayerBase,
  IFCompositeSublayerHighlight,
} IFCompositeSublayer;

@implementation IFConnectorCompositeLayer

+ (id)layerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initWithNode:theNode kind:theKind layoutParameters:theLayoutParameters] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;
  
  kind = theKind;
  IFLayer* baseLayer = (theKind == IFConnectorKindInput
                        ? [IFInputConnectorLayer inputConnectorLayerForNode:theNode layoutParameters:theLayoutParameters]
                        : [IFOutputConnectorLayer outputConnectorLayerForNode:theNode layoutParameters:theLayoutParameters]);

  IFLayer* highlightLayer = [IFConnectorHighlightLayer highlightLayerWithLayoutParameters:theLayoutParameters];
  highlightLayer.frame = baseLayer.frame;
  highlightLayer.hidden = YES;
  highlightLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  
  [self addSublayer:baseLayer];
  [self addSublayer:highlightLayer];
  
  return self;
}

- (BOOL)isInputConnector;
{
  return kind == IFConnectorKindInput;
}

- (BOOL)isOutputConnector;
{
  return kind == IFConnectorKindOutput;
}

- (IFLayer*)baseLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerBase];
}

- (IFLayer*)highlightLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerHighlight];
}

- (void)layoutSublayers;
{
  ((IFConnectorHighlightLayer*)self.highlightLayer).outlinePath = ((IFConnectorLayer*)self.baseLayer).outlinePath;
  [super layoutSublayers];
}

@end
