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
#import "IFTreeView.h"
#import "IFPaletteView2.h"
#import "IFLayoutParameters.h"
#import "IFVariable.h"

@interface IFTreePaletteViewController : IFViewController<IFForestViewDelegate> {
  IBOutlet NSObjectController* layoutParametersController;
  IBOutlet IFForestView* forestView;
  IBOutlet IFPaletteView2* paletteView;
  
  IFVariable* cursorsVar;
}

- (void)setDocument:(IFDocument*)document;

@property(readonly, assign) IFVariable* cursorsVar;

// delegate methods
- (void)willBecomeActive:(IFForestView*)nodesView;

@end
