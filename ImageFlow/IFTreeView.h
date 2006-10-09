//
//  IFTreeView.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutSingle.h"
#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFGrabableViewMixin.h"

extern NSString* IFMarkPboardType;
extern NSString* IFTreeNodesPboardType;

@interface IFTreeView : NSControl {
  IFGrabableViewMixin* grabableViewMixin;

  IFDocument* document;
  unsigned int upToDateLayers;
  NSMutableArray* layoutLayers;
  NSMutableArray* trackingRectTags;
  IFTreeLayoutElement* pointedElement;
  NSBezierPath* highlightingPath;

  BOOL showThumbnails;
  float columnWidth;

  NSFont* labelFont;
  float labelFontHeight;
  
  NSButtonCell* deleteButtonCell;
  NSBezierPath* sidePanePath;

  NSColor* connectorColor;
  NSColor* connectorLabelColor;
  float connectorArrowSize;

  NSColor* cursorColor;
  NSColor* markBackgroundColor;
  NSColor* highlightingColor;
  
  NSMutableDictionary* layoutNodes;
  NSMutableDictionary* layoutThumbnails;
}

- (void)setDocument:(IFDocument*)document;
- (IFDocument*)document;

- (float)columnWidth;
- (void)setColumnWidth:(float)theColumnWidth;

- (float)nodeInternalMargin;
- (NSFont*)labelFont;
- (float)labelFontHeight;

- (NSColor*)sidePaneColor;
- (NSSize)sidePaneSize;
- (NSBezierPath*)sidePanePath;
- (NSButtonCell*)deleteButtonCell;

- (NSColor*)connectorColor;
- (NSColor*)connectorLabelColor;
- (float)connectorArrowSize;

- (NSColor*)cursorColor;
- (NSColor*)markBackgroundColor;

- (NSSize)idealSize;

- (BOOL)showThumbnails;
- (void)setShowThumbnails:(BOOL)theValue;

- (IBAction)makeNodeAlias:(id)sender;
- (IBAction)toggleNodeFoldingState:(id)sender;

- (IBAction)setBookmark:(id)sender;
- (IBAction)removeBookmark:(id)sender;
- (IBAction)goToBookmark:(id)sender;

@end
