//
//  IFNodeLayoutManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 11.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"

typedef enum {
  IFLayerNeededIn  = 0x1,
  IFLayerNeededOut = 0x2
} IFLayerNeededMask;

@class IFForestLayoutManager;
@protocol IFForestLayoutManagerDelegate
- (void)layoutManager:(IFForestLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)layer;
@end

@interface IFForestLayoutManager : NSObject {
  IFTree* tree; // not retained
  float columnWidth;
  id<IFForestLayoutManagerDelegate> delegate; // not retained
}

+ (IFLayerNeededMask)layersNeededFor:(IFTreeNode*)node inTree:(IFTree*)tree;

+ (id)forestLayoutManager;

@property(assign) IFTree* tree;
@property float columnWidth;
@property(assign) id<IFForestLayoutManagerDelegate> delegate;

- (void)layoutSublayersOfLayer:(CALayer*)layer;

@end
