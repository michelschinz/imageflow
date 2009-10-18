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
#import "IFInputConnectorLayer.h"
#import "IFOutputConnectorLayer.h"
#import "IFLayoutParameters.h"

@interface IFForestLayoutManager ()
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

- (void) dealloc;
{
  OBJC_RELEASE(layoutParameters);
  [super dealloc];
}

@synthesize layoutParameters;
@synthesize tree;
@synthesize delegate;

- (void)layoutSublayersOfLayer:(CALayer*)parentLayer;
{
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
    dx += CGRectGetWidth(layers.boundingBox) + [IFLayoutParameters gutterWidth];
  }
  
  // Horizontally center all layers in the root layer, if needed
  IFLayerSet* allLayers = [IFLayerSubsetComposites compositeSubsetOf:[IFLayerSetExplicit layerSetWithLayers:parentLayer.sublayers]];
  float dWidth = CGRectGetWidth(parentLayer.frame) - CGRectGetWidth([allLayers boundingBox]);
  if (dWidth > 0)
    [allLayers translateByX:round(dWidth / 2.0) Y:0];

  if (delegate != nil)
    [delegate layoutManager:self didLayoutSublayersOfLayer:parentLayer];
}

// MARK: -
// MARK: PRIVATE

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
      dx += CGRectGetWidth(parentLayers.boundingBox) + [IFLayoutParameters gutterWidth];
    }
    
    IFCompositeLayer* directParentLayer = (IFCompositeLayer*)[parentLayers lastLayer];
    NSAssert(directParentLayer.node == parent, @"internal error");
    [directParentLayers addLayer:directParentLayer];
  }

  // Layout parent output connectors, if any.
  if (parentsCount > 1) {
    for (int i = 0; i < parentsCount; ++i) {
      IFCompositeLayer* outputConnectorCompositeLayer = [outConnectorLayers objectForKey:[parents objectAtIndex:i]];
      outputConnectorCompositeLayer.hidden = parentsInFoldedSubtree;

      const CGRect currFrame = [directParentLayers layerAtIndex:i].frame;
      const float currWidth = CGRectGetWidth(currFrame), currLeft = CGRectGetMinX(currFrame), currRight = CGRectGetMaxX(currFrame);
      
      IFOutputConnectorLayer* outputConnectorLayer = (IFOutputConnectorLayer*)outputConnectorCompositeLayer.baseLayer;
      outputConnectorLayer.label = [root nameOfParentAtIndex:i];
      outputConnectorLayer.leftReach = (i > 0
                                        ? round((currLeft - CGRectGetMaxX([directParentLayers layerAtIndex:i-1].frame)) / 2.0)
                                        : 0.0);
      outputConnectorLayer.rightReach = (i < parentsCount - 1
                                         ? round((CGRectGetMinX([directParentLayers layerAtIndex:i+1].frame) - currRight) / 2.0)
                                         : 0.0);
      outputConnectorLayer.width = outputConnectorLayer.leftReach + currWidth + outputConnectorLayer.rightReach;
      
      outputConnectorCompositeLayer.position = CGPointMake(currLeft - outputConnectorLayer.leftReach, 0);
      
      if (i == 0 && !parentsInFoldedSubtree)
        [allLayers translateByX:0 Y:CGRectGetHeight(outputConnectorCompositeLayer.frame)];
      [allLayers addLayer:outputConnectorCompositeLayer];
    }
  }
    
  const float directParentsLeft = CGRectGetMinX(directParentLayers.firstLayer.frame);
  const float directParentsRight = CGRectGetMaxX(directParentLayers.lastLayer.frame);
  
  IFCompositeLayer* rootLayer = [nodeLayers objectForKey:root];
  const CGSize rootSize = rootLayer.bounds.size;
  const float rootColumnLeft = fmax(round(directParentsLeft + (directParentsRight - directParentsLeft - rootSize.width) / 2.0), 0.0);

  // Layout input connector
  if (parentsCount > 0) {
    IFCompositeLayer* inputConnectorCompositeLayer = [inConnectorLayers objectForKey:root];
    IFInputConnectorLayer* inputConnectorLayer = (IFInputConnectorLayer*)inputConnectorCompositeLayer.baseLayer;
    inputConnectorCompositeLayer.hidden = parentsInFoldedSubtree;
    if (parentsCount == 1)
      inputConnectorLayer.width = fmin(CGRectGetWidth([directParentLayers lastLayer].frame), rootSize.width) - 2.0 * [IFLayoutParameters nodeInternalMargin];
    else
      inputConnectorLayer.width = rootSize.width - 2.0 * [IFLayoutParameters nodeInternalMargin];
    inputConnectorCompositeLayer.position = CGPointMake(rootColumnLeft + [IFLayoutParameters nodeInternalMargin], 0);
    
    if (!parentsInFoldedSubtree)
      [allLayers translateByX:0 Y:CGRectGetHeight(inputConnectorCompositeLayer.frame)];
    [allLayers addLayer:inputConnectorCompositeLayer];
  }
  
  // Layout root
  rootLayer.hidden = inFoldedSubtree;
  rootLayer.frame = (CGRect){ CGPointMake(rootColumnLeft, 0.0), rootSize };
  if (!inFoldedSubtree)
    [allLayers translateByX:0.0 Y:CGRectGetHeight(rootLayer.bounds)];
  [allLayers addLayer:rootLayer];
    
  return allLayers;
}

@end
