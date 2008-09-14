//
//  IFConnectorCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorCompositeLayer.h"

#import "IFBaseLayer.h"
#import "IFHighlightLayer.h"
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
  [self addSublayer:(theKind == IFConnectorKindInput
                     ? [IFInputConnectorLayer inputConnectorLayerWithNode:theNode layoutParameters:theLayoutParameters]
                     : [IFOutputConnectorLayer outputConnectorLayerWithNode:theNode layoutParameters:theLayoutParameters])];
  [self addSublayer:[IFHighlightLayer highlightLayerWithLayoutParameters:theLayoutParameters]];
  
  // Hide all layers but the base
  self.highlightLayer.hidden = YES;
  
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

- (IFBaseLayer*)baseLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerBase];
}

- (IFLayer*)highlightLayer;
{
  return [self.sublayers objectAtIndex:IFCompositeSublayerHighlight];
}

@end
