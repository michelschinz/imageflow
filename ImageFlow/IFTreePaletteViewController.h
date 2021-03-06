//
//  IFTreePaletteViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFForestView.h"
#import "IFPaletteView.h"
#import "IFLayoutParameters.h"
#import "IFVariable.h"

@interface IFTreePaletteViewController : NSViewController<IFForestViewDelegate, IFPaletteViewDelegate> {
  IBOutlet IFForestView* forestView;
  IBOutlet IFPaletteView* paletteView;

  IFDocument* document;
  IFVariable* cursorsVar;
  IFTreeTemplate* cachedSelectedTreeTemplate;
}

@property(retain, nonatomic) IFDocument* document;
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
