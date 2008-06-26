//
//  IFSingleWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 26.06.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeViewController.h"
#import "IFImageOrErrorViewController.h"
#import "IFHUDWindowController.h"

@interface IFSingleWindowController : NSWindowController {
  IFTreeViewController* treeViewController;

  IFImageOrErrorViewController* imageViewController;
  IFHUDWindowController* hudWindowController;
}

@end
