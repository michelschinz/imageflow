//
//  IFTreeViewWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeViewController.h"
#import "IFTreeCursorPair.h"

@interface IFTreeViewWindowController : NSWindowController {
  IFTreeViewController* treeViewController;
}

- (IFTreeCursorPair*)cursorPair;

@end
