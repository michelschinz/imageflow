//
//  IFTreeViewWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeViewWindowController.h"
#import "IFDocument.h"

@implementation IFTreeViewWindowController

- (id)init;
{
  if (![super initWithWindowNibName:@"IFTreeWindow"])
    return nil;
  treeViewController = [IFTreeViewController new];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(treeViewController);
  [super dealloc];
}

- (void)awakeFromNib;
{
  NSWindow* window = [self window];
  [window setDisplaysWhenScreenProfileChanges:YES];
  [window setFrameAutosaveName:@"IFTreeView"];
  [window setContentView:[treeViewController topLevelView]];
  
  [treeViewController setDocument:[self document]];
}

- (IFTreeCursorPair*)cursorPair;
{
  return [treeViewController cursors];
}

@end
