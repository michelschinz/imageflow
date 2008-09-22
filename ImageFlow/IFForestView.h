//
//  IFForestView.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFDocument.h"
#import "IFTreeLayoutParameters.h"
#import "IFTreeCursorPair.h"
#import "IFCompositeLayer.h"
#import "IFLayerSet.h"
#import "IFForestLayoutManager.h"

@class IFForestView;
@protocol IFForestViewDelegate
- (void)willBecomeActive:(IFForestView*)forestView;
@end

@interface IFForestView : NSView<IFForestLayoutManagerDelegate> {
  IFGrabableViewMixin* grabableViewMixin;
  
  IFDocument* document;

  // Cursors and selection
  IFTreeCursorPair* cursors;
  NSMutableSet* selectedNodes;

  // Marks
  NSArray* marks;
  
  // Drag&drop
  BOOL isCurrentDragLocal;
  NSDragOperation currentDragOperation;
  IFCompositeLayer* highlightedLayer;
  
  // Delegate
  id<IFForestViewDelegate> delegate;
}

@property(assign) IFDocument* document;
@property(readonly, assign) IFTreeCursorPair* cursors;

@property(assign) id<IFForestViewDelegate> delegate;

// MARK: IFNodeLayoutManagerDelegate methods
- (void)layoutManager:(IFForestLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)parent;

@end
