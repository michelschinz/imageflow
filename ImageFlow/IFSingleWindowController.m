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

static NSString* IFImageViewModeDidChange = @"IFImageViewModeDidChange";
static NSString* IFActiveViewDidChange = @"IFActiveViewDidChange";

- (id)init;
{
  if (![super initWithWindowNibName:@"IFSingleWindow"])
    return nil;
  treeViewController = [IFTreeViewController new];
  imageViewController = [IFImageOrErrorViewController new];
  hudWindowController = [IFHUDWindowController new];

  [imageViewController addObserver:self forKeyPath:@"mode" options:0 context:IFImageViewModeDidChange];
  [imageViewController addObserver:self forKeyPath:@"activeView" options:0 context:IFActiveViewDidChange];

  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(hudWindowController);
  OBJC_RELEASE(imageViewController);
  OBJC_RELEASE(treeViewController);
  [super dealloc];
}

- (void)awakeFromNib;
{
  NSWindow* window = [self window];
  [window setDisplaysWhenScreenProfileChanges:YES];

  NSArray* views = [[window contentView] subviews];
  NSAssert([views count] == 1, @"unexpected number of sub-views");
  NSSplitView* splitView = [views objectAtIndex:0];

  [splitView replaceSubview:[[splitView subviews] objectAtIndex:0] with:[treeViewController topLevelView]];
  [splitView replaceSubview:[[splitView subviews] objectAtIndex:1] with:[imageViewController topLevelView]];

  [treeViewController setDocument:[self document]];
}

- (void)windowDidLoad;
{
  [imageViewController setCanvasBounds:[IFVariableKVO variableWithKVOCompliantObject:[self document] key:@"canvasBounds"]];
  [imageViewController setCursorPair:[treeViewController cursors]];
  
  [hudWindowController setCursorPair:[treeViewController cursors]];
  [hudWindowController setUnderlyingWindow:[self window]];
  [hudWindowController setUnderlyingView:[imageViewController activeView]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFActiveViewDidChange) {
    [hudWindowController setUnderlyingView:[imageViewController activeView]];
  } else if (context == IFImageViewModeDidChange) {
    [hudWindowController setVisible:([imageViewController mode] == IFImageViewModeEdit)];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

@end
