//
//  IFSingleWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.06.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreePaletteViewController.h"
#import "IFImageOrErrorViewController.h"
#import "IFFilterSettingsViewController.h"

@interface IFSingleWindowController : NSWindowController {
  IFTreePaletteViewController* treeViewController;
  IFImageOrErrorViewController* imageViewController;
  IFFilterSettingsViewController* filterSettingsViewController;
}

@end
