//
//  IFTreeViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeViewController.h"
#import "IFCenteringClipView.h"

@implementation IFTreeViewController

- (id)init;
{
  return [super initWithViewNibName:@"IFTreeView"];
}

- (void)awakeFromNib;
{
  NSView* docView = [[[scrollView documentView] retain] autorelease];
  IFCenteringClipView* newClipView = [[[IFCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]] autorelease];
  [newClipView setBackgroundColor:[[treeView layoutParameters] backgroundColor]];
  [newClipView setCenterVertically:NO];
  [scrollView setContentView:newClipView];
  [scrollView setDocumentView:docView];
}

- (IFTreeView*)treeView;
{
  return treeView;
}

@end
