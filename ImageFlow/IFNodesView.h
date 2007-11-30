//
//  IFNodesView.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFTreeLayoutParameters.h"
#import "IFDocument.h"
#import "IFTreeLayoutElement.h"

extern NSString* IFMarkPboardType;
extern NSString* IFTreePboardType;

@interface IFNodesView : NSControl {
  IFGrabableViewMixin* grabableViewMixin;

  IBOutlet IFTreeLayoutParameters* layoutParameters;

  IFDocument* document;
  unsigned int upToDateLayers;
  NSMutableArray* layoutLayers;
}

- (id)initWithFrame:(NSRect)frame layersCount:(int)layersCount;

- (void)setDocument:(IFDocument*)document;
- (IFDocument*)document;

- (IFTree*)tree;

- (IFTreeLayoutParameters*)layoutParameters;
- (IFTreeLayoutElement*)layoutLayerAtIndex:(int)index;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point inLayerAtIndex:(int)layerIndex;
- (void)invalidateLayout;
- (void)invalidateLayoutLayer:(int)layoutLayer;

- (void)layoutDidChange;

// protected, abstract
- (IFTreeLayoutElement*)layoutForLayer:(int)layer;

@end
