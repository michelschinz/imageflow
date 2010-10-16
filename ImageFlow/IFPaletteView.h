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
#import "IFTreeTemplate.h"

typedef enum {
  IFPaletteViewModeNormal,
  IFPaletteViewModePreview
} IFPaletteViewMode;

@class IFPaletteView;
@protocol IFPaletteViewDelegate
- (void)paletteViewWillBecomeActive:(IFPaletteView*)paletteView;
@end

@interface IFPaletteView : NSView<IFPaletteLayoutManagerDelegate> {
  IFGrabableViewMixin* grabableViewMixin;

  IFDocument* document;
  
  IFPaletteViewMode mode;
  NSString* previewModeFilterString;
  
  IFTreeCursorPair* cursors;
  IFTreeCursorPair* visualisedCursor;

  NSMutableArray* templates;
  NSArray* normalModeTrees;
  
  BOOL acceptFirstResponder;
  
  id<IFPaletteViewDelegate> delegate;
}

@property(assign, nonatomic) IFDocument* document;
@property(readonly) IFTreeCursorPair* cursors;
@property(retain) IFTreeCursorPair* visualisedCursor;

@property(assign) id<IFPaletteViewDelegate> delegate;

- (void)switchToPreviewModeForNode:(IFTreeNode*)node;
- (void)switchToNormalMode;
@property(readonly) IFPaletteViewMode mode;
@property(copy) NSString* previewModeFilterString;

@property(readonly, retain) IFTreeTemplate* selectedTreeTemplate;
- (BOOL)selectPreviousTreeTemplate;
- (BOOL)selectNextTreeTemplate;

@end
