//
//  IFTreeViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFViewController.h"
#import "IFTreeView.h"
#import "IFPaletteView.h"
#import "IFTreeLayoutParameters.h"

@interface IFTreeViewController : IFViewController {
  IBOutlet IFTreeLayoutParameters* layoutParameters;
  IBOutlet IFTreeView* treeView;
  IBOutlet IFPaletteView* paletteView;
}

- (void)setDocument:(IFDocument*)document;

- (IFTreeCursorPair*)cursors;

@end
