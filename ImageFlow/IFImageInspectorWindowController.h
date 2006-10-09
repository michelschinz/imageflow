//
//  IFImageInspectorWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFProbeWindowController.h"
#import "IFImageView.h"
#import "IFExpressionEvaluator.h"
#import "IFImageVariant.h"

typedef enum {
  IFImageInspectorModeView,
  IFImageInspectorModeEdit,
} IFImageInspectorMode;

typedef enum {
  IFImageInspectorLayoutSingle,
  IFImageInspectorLayoutDual,
  IFImageInspectorLayoutSplitH,
  IFImageInspectorLayoutSplitV,
} IFImageInspectorLayout;

@interface IFImageInspectorWindowController : IFProbeWindowController<IFImageViewDelegate> {
  IBOutlet IFImageView* imageView;
  IBOutlet RBSplitSubview* filterSettingsSubView;
  IBOutlet NSTabView* filterSettingsTabView;
  IBOutlet NSTextField* filterNameTextField;
  
  IBOutlet NSWindow* thumbnailWindow;
  IBOutlet IFImageView* thumbnailView;
  
  IBOutlet NSWindow* mainVariantWindow;
  IBOutlet NSPopUpButton* mainVariantButton;

  IFImageInspectorMode mode;
  IFImageInspectorLayout layout;

  IFTreeNode* currentNode;
  NSObject<IFFilterDelegate>* filterDelegate;
  unsigned filterDelegateCapabilities;
  NSMutableDictionary* filterControllers;
  NSMutableDictionary* tabIndices;
  NSMutableDictionary* panelSizes;
  NSArray* variants;
  IFImageVariant* activeVariant;
  IFProbe* secondaryProbe;
  IFTreeNode* currentSecondaryNode;
  NSAffineTransform* editViewTransform;
  NSAffineTransform* viewEditTransform;

  NSValue* proxy;
  NSView* toolbarItems;
  NSToolbarItem* modeToolbarItem;
  NSToolbarItem* layoutToolbarItem;
  NSToolbarItem* zoomToolbarItem;
}

- (void)setMode:(IFImageInspectorMode)newMode;
- (IFImageInspectorMode)mode;

- (void)setLayout:(IFImageInspectorLayout)newLayout;
- (IFImageInspectorLayout)layout;

- (NSArray*)variants;
- (void)setVariants:(NSArray*)newVariants;

- (IFImageVariant*)activeVariant;
- (void)setActiveVariant:(IFImageVariant*)newActiveVariant;

@end
