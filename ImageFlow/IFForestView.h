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
#import "IFSplittableTreeCursorPair.h"
#import "IFCompositeLayer.h"
#import "IFLayerSet.h"
#import "IFForestLayoutManager.h"
#import "IFVariable.h"
#import "IFTree.h"
#import "IFTreeTemplate.h"

@class IFForestView;
@protocol IFForestViewDelegate
- (void)forestViewWillBecomeActive:(IFForestView*)forestView;

- (void)beginPreviewForNode:(IFTreeNode*)node ofTree:(IFTree*)tree;
- (void)previewFilterStringDidChange:(NSString*)newFilterString;
- (IFTreeTemplate*)selectedTreeTemplate;
- (BOOL)selectPreviousTreeTemplate;
- (BOOL)selectNextTreeTemplate;
- (void)endPreview;
@end

@interface IFForestView : NSView<IFForestLayoutManagerDelegate> {
  IFGrabableViewMixin* grabableViewMixin;
  
  IFDocument* document;
  IFVariable* canvasBoundsVar;

  IBOutlet NSButton* viewLockButton;
  
  // Cursors and selection
  IFSplittableTreeCursorPair* cursors;
  IFTreeCursorPair* visualisedCursor;
  NSMutableSet* selectedNodes;
  NSInvocation* delayedMouseEventInvocation;

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
@property(readonly, retain) IFTreeCursorPair* cursors;
@property(retain) IFTreeCursorPair* visualisedCursor;
@property float columnWidth;

@property(assign) id<IFForestViewDelegate> delegate;

// MARK: IFNodeLayoutManagerDelegate methods
- (void)layoutManager:(IFForestLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)parent;

@end
