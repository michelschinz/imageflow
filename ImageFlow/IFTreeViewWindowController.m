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
  
  [[treeViewController treeView] setDocument:[self document]];
}

- (IFTreeCursorPair*)cursorPair;
{
  return [[treeViewController treeView] cursors];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)defaultFrame;
{
  IFTreeView* treeView = [treeViewController treeView];
  NSRect windowFrame = [window frame];
  NSSize visibleViewSize = [treeView visibleRect].size;
  NSSize idealViewSize = [treeView idealSize];
  NSSize minSize = [window minSize];

  float deltaW = fmax(idealViewSize.width - visibleViewSize.width,  minSize.width - NSWidth(windowFrame));
  float deltaH = fmax(idealViewSize.height - visibleViewSize.height, minSize.height - NSHeight(windowFrame));

  windowFrame.size.width += deltaW;
  windowFrame.size.height += deltaH;
  windowFrame.origin.y -= deltaH;
  return windowFrame;
}

@end
