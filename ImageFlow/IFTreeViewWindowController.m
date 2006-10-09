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
  return [super initWithWindowNibName:@"IFTreeView"];
}

- (void)awakeFromNib;
{
  [treeView setDocument:[self document]];
  [[self window] setDisplaysWhenScreenProfileChanges:YES];
  [[self window] setFrameAutosaveName:@"IFTreeView"];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)defaultFrame;
{
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
