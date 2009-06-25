//
//  IFConnectorCompositeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorCompositeLayer.h"

#import "IFLayoutParameters.h"

@implementation IFConnectorCompositeLayer

+ (id)layerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  return [[[self alloc] initWithNode:theNode kind:theKind] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  if (![super init])
    return nil;
  
  baseLayer = [IFConnectorLayer connectorLayerForNode:theNode kind:theKind];
  baseLayer.anchorPoint = CGPointZero;
  baseLayer.fillColor = [IFLayoutParameters connectorColor];
  [self addSublayer:baseLayer];

  highlightLayer = [IFPathLayer layer];
  highlightLayer.anchorPoint = CGPointZero;
  highlightLayer.lineWidth = [IFLayoutParameters selectionWidth];
  highlightLayer.strokeColor = [IFLayoutParameters highlightBorderColor];
  highlightLayer.fillColor = [IFLayoutParameters highlightBackgroundColor];
  highlightLayer.hidden = YES;
  [self addSublayer:highlightLayer];
  
  return self;
}

- (BOOL)isInputConnector;
{
  return baseLayer.kind == IFConnectorKindInput;
}

- (BOOL)isOutputConnector;
{
  return baseLayer.kind == IFConnectorKindOutput;
}

@synthesize baseLayer, highlightLayer;

- (void)layoutSublayers;
{
  highlightLayer.path = baseLayer.path;
  [super layoutSublayers];
}

@end
