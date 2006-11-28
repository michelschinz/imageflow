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

@interface IFTreeViewController : IFViewController {
  IBOutlet IFTreeView* treeView;
  IBOutlet NSScrollView* scrollView;
}

- (IFTreeView*)treeView;

@end
