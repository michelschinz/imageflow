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
#import "IFTreeCursorPair.h"

extern NSString* IFMarkPboardType;
extern NSString* IFTreePboardType;

@protocol IFNodesViewDelegate
- (void)willBecomeActive:(IFNodesView*)nodeView;
@end

@interface IFNodesView : NSView {
  IFGrabableViewMixin* grabableViewMixin;

  IBOutlet IFTreeLayoutParameters* layoutParameters;

  IFDocument* document; // not retained, to avoid cycles
  IFTreeCursorPair* cursors;
  unsigned int upToDateLayers;
  NSMutableArray* layoutLayers;
  
  IBOutlet id<IFNodesViewDelegate> delegate;
}

- (id)initWithFrame:(NSRect)frame layersCount:(int)layersCount;

@property(assign) IFDocument* document;
@property(readonly, assign) IFTreeCursorPair* cursors;

- (IFTree*)tree;

@property(readonly, assign) IFTreeLayoutParameters* layoutParameters;
- (IFTreeLayoutElement*)layoutLayerAtIndex:(int)index;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)point inLayerAtIndex:(int)layerIndex;
- (void)invalidateLayout;
- (void)invalidateLayoutLayer:(int)layoutLayer;

- (void)layoutDidChange;

@property(assign) id<IFNodesViewDelegate> delegate;

// protected, abstract
- (IFTreeLayoutElement*)layoutForLayer:(int)layer;

@end
