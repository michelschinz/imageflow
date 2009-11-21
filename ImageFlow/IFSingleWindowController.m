//
//  IFSingleWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.06.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFSingleWindowController.h"
#import "IFVariableKVO.h"

@implementation IFSingleWindowController

- (id)init;
{
  if (![super initWithWindowNibName:@"IFSingleWindow"])
    return nil;
  treeViewController = [IFTreePaletteViewController new];
  imageViewController = [IFImageOrErrorViewController new];
  filterSettingsViewController = [IFFilterSettingsViewController new];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(filterSettingsViewController);
  OBJC_RELEASE(imageViewController);
  OBJC_RELEASE(treeViewController);
  [super dealloc];
}

- (void)awakeFromNib;
{
  NSWindow* window = [self window];
  [window setDisplaysWhenScreenProfileChanges:YES];

  IFDocument* doc = self.document;
  [imageViewController postInitWithCursorsVar:treeViewController.cursorsVar canvasBoundsVar:[IFVariableKVO variableWithKVOCompliantObject:doc key:@"canvasBounds"] layoutParameters:doc.layoutParameters];
  [filterSettingsViewController postInitWithCursorsVar:treeViewController.cursorsVar];
  
  NSArray* views = [[window contentView] subviews];
  NSAssert([views count] == 1, @"unexpected number of sub-views");
  NSSplitView* splitView = [views objectAtIndex:0];

  [splitView replaceSubview:[[splitView subviews] objectAtIndex:0] with:treeViewController.view];
  [splitView replaceSubview:[[splitView subviews] objectAtIndex:1] with:imageViewController.view];
  [splitView replaceSubview:[[splitView subviews] objectAtIndex:2] with:filterSettingsViewController.view];

  [treeViewController setDocument:self.document];
}

@end
