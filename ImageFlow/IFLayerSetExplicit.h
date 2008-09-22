//
//  IFLayerGroupExplicit.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayerSet.h"

@interface IFLayerSetExplicit : IFLayerSet {
  NSMutableArray* layers;
}

+ (id)layerSet;
+ (id)layerSetWithLayers:(NSArray*)theLayers;

- (id)initWithLayers:(NSArray*)theLayers;

- (void)addLayer:(CALayer*)layer;
- (void)addLayersFromGroup:(IFLayerSet*)group;

@end
