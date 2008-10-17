//
//  IFNodeLayoutManager.m
//  ImageFlow
//
//  Created by Michel Schinz on 11.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFForestLayoutManager.h"
#import "IFNodeLayer.h"
#import "IFNodeCompositeLayer.h"
#import "IFLayerSet.h"
#import "IFLayerSetExplicit.h"
#import "IFLayerSubsetComposites.h"
#import "IFOutputConnectorLayer.h"
#import "IFLayoutParameters.h"

@interface IFForestLayoutManager (Private)
- (BOOL)checkLayersStartingAt:(IFTreeNode*)root withNodeLayers:(NSDictionary*)nodeLayers inConnectorLayers:(NSDictionary*)inConnectorLayers outConnectorLayers:(NSDictionary*)outConnectorLayers;
- (IFLayerSet*)layoutTreeStartingAt:(IFTreeNode*)root usingNodeLayers:(NSDictionary*)layers inConnectorLayers:(NSDictionary*)inConnectorLayers outConnectorLayers:(NSDictionary*)outConnectorLayers inFoldedSubtree:(BOOL)inFoldedSubtree;
@end

@implementation IFForestLayoutManager

+ (IFLayerNeededMask)layersNeededFor:(IFTreeNode*)node inTree:(IFTree*)tree;
{
  IFLayerNeededMask answer = 0;
  
  if ([tree parentsOfNode:node].count > 0)
    answer |= IFLayerNeededIn;
  
  IFTreeNode* child = [tree childOfNode:node];
  if (child != tree.root && [tree parentsOfNode:child].count > 1)
    answer |= IFLayerNeededOut;
    
  return answer;
}

+ (id)forestLayoutManager;
{
  return [[[self alloc] init] autorelease];
}

@synthesize tree;

@synthesize delegate;

- (void)layoutSublayersOfLayer:(CALayer*)parentLayer;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  // Find all layers and associate them with their node
  NSMutableDictionary* nodeLayers = [createMutableDictionaryWithRetainedKeys() autorelease];
  NSMutableDictionary* inConnectorLayers = [createMutableDictionaryWithRetainedKeys() autorelease];
  NSMutableDictionary* outConnectorLayers = [createMutableDictionaryWithRetainedKeys() autorelease];

  IFLayerSubsetComposites* mySublayers = [IFLayerSubsetComposites compositeSubsetOf:[IFLayerSetExplicit layerSetWithLayers:parentLayer.sublayers]];
  for (IFCompositeLayer* layer in mySublayers) {
    NSMutableDictionary* dict;
    if (layer.isNode)
      dict = nodeLayers;
    else if (layer.isInputConnector)
      dict = inConnectorLayers;
    else
      dict = outConnectorLayers;
    
    CFDictionarySetValue((CFMutableDictionaryRef)dict, layer.node, layer);
  }

  // Check that all layers exist, and if not, abort layout.
  for (IFTreeNode* root in [tree parentsOfNode:tree.root]) {
    if (![self checkLayersStartingAt:root withNodeLayers:nodeLayers inConnectorLayers:inConnectorLayers outConnectorLayers:outConnectorLayers])
      return;
  }
  
  // Layout all trees
  float dx = 0.0;
  for (IFTreeNode* root in [tree parentsOfNode:tree.root]) {
    IFLayerSet* layers = [self layoutTreeStartingAt:root usingNodeLayers:nodeLayers inConnectorLayers:inConnectorLayers outConnectorLayers:outConnectorLayers inFoldedSubtree:NO];
    [layers translateByX:dx Y:0];
    dx += CGRectGetWidth(layers.boundingBox) + layoutParameters.gutterWidth;
  }
  
  // Horizontally center all layers in the root layer, if needed
  IFLayerSet* allLayers = [IFLayerSubsetComposites compositeSubsetOf:[IFLayerSetExplicit layerSetWithLayers:parentLayer.sublayers]];
  float dWidth = CGRectGetWidth(parentLayer.frame) - CGRectGetWidth([allLayers boundingBox]);
  if (dWidth > 0)
    [allLayers translateByX:round(dWidth / 2.0) Y:0];

  if (delegate != nil)
    [delegate layoutManager:self didLayoutSublayersOfLayer:parentLayer];
}

@end

@implementation IFForestLayoutManager (Private)

- (BOOL)checkLayersStartingAt:(IFTreeNode*)root withNodeLayers:(NSDictionary*)nodeLayers inConnectorLayers:(NSDictionary*)inConnectorLayers outConnectorLayers:(NSDictionary*)outConnectorLayers;
{
  if ([nodeLayers objectForKey:root] == nil)
    return NO;
  IFLayerNeededMask layersNeeded = [IFForestLayoutManager layersNeededFor:root inTree:tree];
  if ((layersNeeded & IFLayerNeededIn) && [inConnectorLayers objectForKey:root] == nil)
    return NO;
  if ((layersNeeded & IFLayerNeededOut) && [outConnectorLayers objectForKey:root] == nil)
    return NO;
  NSArray* parents = [tree parentsOfNode:root];
  for (IFTreeNode* parent in parents) {
    if (![self checkLayersStartingAt:parent withNodeLayers:nodeLayers inConnectorLayers:inConnectorLayers outConnectorLayers:outConnectorLayers])
      return NO;
  }
  return YES;
}

- (IFLayerSet*)layoutTreeStartingAt:(IFTreeNode*)root usingNodeLayers:(NSDictionary*)nodeLayers inConnectorLayers:(NSDictionary*)inConnectorLayers outConnectorLayers:(NSDictionary*)outConnectorLayers inFoldedSubtree:(BOOL)inFoldedSubtree;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];

  BOOL parentsInFoldedSubtree = (inFoldedSubtree || root.isFolded);
  IFLayerSetExplicit* allLayers = [IFLayerSetExplicit layerSet];

  NSArray* parents = [tree parentsOfNode:root];
  const int parentsCount = [parents count];

  // Layout parents
  IFLayerSetExplicit* directParentLayers = [IFLayerSetExplicit layerSet];
  float dx = 0.0;
  for (IFTreeNode* parent in parents) {
    IFLayerSet* parentLayers = [self layoutTreeStartingAt:parent usingNodeLayers:nodeLayers inConnectorLayers:inConnectorLayers outConnectorLayers:outConnectorLayers inFoldedSubtree:parentsInFoldedSubtree];
    [allLayers addLayersFromGroup:parentLayers];
    
    if (!parentsInFoldedSubtree) {
      [parentLayers translateByX:dx Y:0.0];
      dx += CGRectGetWidth(parentLayers.boundingBox) + layoutParameters.gutterWidth;
    }
    
    IFCompositeLayer* directParentLayer = (IFCompositeLayer*)[parentLayers lastLayer];
    NSAssert(directParentLayer.node == parent, @"internal error");
    [directParentLayers addLayer:directParentLayer];
  }
  const float parentsWidth = CGRectGetWidth(allLayers.boundingBox);

  // Layout parent output connectors, if any.
  if (parentsCount > 1) {
    for (int i = 0; i < parentsCount; ++i) {
      IFCompositeLayer* outputConnectorCompositeLayer = [outConnectorLayers objectForKey:[parents objectAtIndex:i]];
      outputConnectorCompositeLayer.hidden = parentsInFoldedSubtree;
      
      float currLeft = CGRectGetMinX([directParentLayers layerAtIndex:i].frame);
      
      IFOutputConnectorLayer* outputConnectorLayer = (IFOutputConnectorLayer*)outputConnectorCompositeLayer.baseLayer;
      outputConnectorLayer.label = [root nameOfParentAtIndex:i];
      outputConnectorLayer.leftReach = (i > 0
                                        ? round((currLeft - CGRectGetMinX([directParentLayers layerAtIndex:i-1].frame) - layoutParameters.columnWidth) / 2.0)
                                        : 0.0);
      outputConnectorLayer.rightReach = (i < parentsCount - 1
                                         ? round((CGRectGetMinX([directParentLayers layerAtIndex:i+1].frame) - currLeft - layoutParameters.columnWidth) / 2.0)
                                         : 0.0);
      
      outputConnectorCompositeLayer.bounds = (CGRect){ CGPointZero, [outputConnectorCompositeLayer preferredFrameSize] };
      outputConnectorCompositeLayer.position = CGPointMake(currLeft - outputConnectorLayer.leftReach, 0);
      
      if (i == 0 && !parentsInFoldedSubtree)
        [allLayers translateByX:0 Y:CGRectGetHeight(outputConnectorCompositeLayer.bounds)];
      [allLayers addLayer:outputConnectorCompositeLayer];
    }
  }
    
  const float directParentsLeft = CGRectGetMinX(directParentLayers.firstLayer.frame);
  const float directParentsRight = CGRectGetMaxX(directParentLayers.lastLayer.frame);
  const float rootColumnLeft = fmax(round(directParentsLeft + (directParentsRight - directParentsLeft - layoutParameters.columnWidth) / 2.0), 0.0);

  // Layout input connector
  if (parentsCount > 0) {
    IFCompositeLayer* inputConnectorLayer = [inConnectorLayers objectForKey:root];
    inputConnectorLayer.hidden = parentsInFoldedSubtree;

    inputConnectorLayer.bounds = (CGRect){ CGPointZero, [inputConnectorLayer preferredFrameSize] };
    inputConnectorLayer.position = CGPointMake(rootColumnLeft + layoutParameters.nodeInternalMargin, 0);
    
    if (!parentsInFoldedSubtree)
      [allLayers translateByX:0 Y:CGRectGetHeight(inputConnectorLayer.frame)];
    [allLayers addLayer:inputConnectorLayer];
  }
  
  // Layout root
  CALayer* rootLayer = [nodeLayers objectForKey:root];
  rootLayer.hidden = inFoldedSubtree;
  rootLayer.bounds = (CGRect){ CGPointZero, [rootLayer preferredFrameSize] };
  if (parentsWidth == 0)
    rootLayer.position = CGPointZero;
  else
    rootLayer.position = CGPointMake(rootColumnLeft, 0.0);

  if (!inFoldedSubtree)
    [allLayers translateByX:0.0 Y:CGRectGetHeight(rootLayer.bounds)];
  [allLayers addLayer:rootLayer];
    
  return allLayers;
}

@end
