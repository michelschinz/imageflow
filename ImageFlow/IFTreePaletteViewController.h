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

@interface IFTreePaletteViewController : IFViewController<IFForestViewDelegate> {
  IBOutlet NSObjectController* layoutParametersController;
  IBOutlet IFForestView* forestView;
  IBOutlet IFPaletteView* paletteView;

  IFDocument* document;
  IFVariable* cursorsVar;
}

@property(retain) IFDocument* document;
@property(readonly) IFVariable* cursorsVar;

// MARK: delegate methods

- (void)willBecomeActive:(IFForestView*)nodesView;

- (void)beginPreviewForNode:(IFTreeNode*)node ofTree:(IFTree*)tree;
- (void)endPreview;

@end
