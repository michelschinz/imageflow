//
//  IFPaletteView.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFForestView.h"
#import "IFPaletteLayoutManager.h"
#import "IFTree.h"
#import "IFTreeNode.h"

typedef enum {
  IFPaletteViewModeNormal,
  IFPaletteViewModePreview
} IFPaletteViewMode;
 
@interface IFPaletteView : NSView<IFPaletteLayoutManagerDelegate> {
  IFGrabableViewMixin* grabableViewMixin;

  IFPaletteViewMode mode;
  
  // Cursors & selection
  IFTreeCursorPair* cursors;

  // Templates
  NSMutableArray* templates;
  NSArray* normalModeTrees;
  
  // First responder
  BOOL acceptFirstResponder;
  
  // Delegate
  id<IFForestViewDelegate> delegate;
}

- (void)switchToPreviewModeForNode:(IFTreeNode*)node ofTree:(IFTree*)tree canvasBounds:(IFVariable*)canvasBoundsVar;
- (void)switchToNormalMode;
@property(readonly) IFPaletteViewMode mode;

@property(assign) id<IFForestViewDelegate> delegate;

@end
