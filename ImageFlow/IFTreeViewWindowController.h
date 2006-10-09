//
//  IFTreeViewWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeView.h"

@interface IFTreeViewWindowController : NSWindowController {
  IBOutlet IFTreeView* treeView;
}

@end
