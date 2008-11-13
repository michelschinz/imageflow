//
//  IFTreeViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFViewController.h"
#import "IFForestView.h"
#import "IFPaletteView.h"
#import "IFLayoutParameters.h"
#import "IFVariable.h"

@interface IFTreePaletteViewController : IFViewController<IFForestViewDelegate, IFPaletteViewDelegate> {
  IBOutlet NSObjectController* layoutParametersController;
  IBOutlet IFForestView* forestView;
  IBOutlet IFPaletteView* paletteView;

  IFDocument* document;
  IFVariable* cursorsVar;
  IFTreeTemplate* cachedSelectedTreeTemplate;
}

@property(retain) IFDocument* document;
@property float columnWidth;
@property(readonly) IFVariable* cursorsVar;

// MARK: IFForestView delegate methods
- (void)forestViewWillBecomeActive:(IFForestView*)view;
- (void)beginPreviewForNode:(IFTreeNode*)node ofTree:(IFTree*)tree;
- (void)previewFilterStringDidChange:(NSString*)newFilterString;
- (IFTreeTemplate*)selectedTreeTemplate;
- (BOOL)selectPreviousTreeTemplate;
- (BOOL)selectNextTreeTemplate;
- (void)endPreview;

// MARK: IFPaletteView delegate methods
- (void)paletteViewWillBecomeActive:(IFPaletteView*)newPaletteView;

@end
