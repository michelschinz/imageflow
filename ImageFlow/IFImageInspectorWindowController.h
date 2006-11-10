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

@interface IFImageInspectorWindowController : IFProbeWindowController<IFImageViewDelegate> {
  IBOutlet NSTabView* imageOrErrorTabView;
  IBOutlet IFImageView* imageView;
  IBOutlet RBSplitSubview* filterSettingsSubView;
  IBOutlet NSTabView* filterSettingsTabView;
  IBOutlet NSTextField* filterNameTextField;
  
  IBOutlet NSWindow* thumbnailWindow;
  IBOutlet IFImageView* thumbnailView;
  
  IFImageInspectorMode mode;
  BOOL locked;

  IFExpressionEvaluator* evaluator;
  IFExpression* mainExpression;
  IFExpression* thumbnailExpression;
  NSString* errorMessage;
  
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
  NSToolbarItem* variantToolbarItem;
  NSToolbarItem* lockedToolbarItem;
  NSToolbarItem* zoomToolbarItem;
}

- (void)setMode:(IFImageInspectorMode)newMode;
- (IFImageInspectorMode)mode;

- (void)setLocked:(BOOL)newLocked;
- (BOOL)locked;

- (NSArray*)variants;
- (void)setVariants:(NSArray*)newVariants;

- (IFImageVariant*)activeVariant;
- (void)setActiveVariant:(IFImageVariant*)newActiveVariant;

@end
