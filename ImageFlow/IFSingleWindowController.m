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
  treeViewController = [IFTreePaletteViewController new];
  imageViewController = [IFImageOrErrorViewController new];
  hudWindowController = [IFHUDWindowController new];

  [imageViewController addObserver:self forKeyPath:@"mode" options:0 context:IFImageViewModeDidChange];
  [imageViewController addObserver:self forKeyPath:@"activeView" options:0 context:IFActiveViewDidChange];

  return self;
}

- (void)dealloc;
{
  [imageViewController removeObserver:self forKeyPath:@"activeView"];
  [imageViewController removeObserver:self forKeyPath:@"mode"];
  
  OBJC_RELEASE(hudWindowController);
  OBJC_RELEASE(imageViewController);
  OBJC_RELEASE(treeViewController);
  [super dealloc];
}

- (void)awakeFromNib;
{
  NSWindow* window = [self window];
  [window setDisplaysWhenScreenProfileChanges:YES];

  [imageViewController postInitWithCursorsVar:[treeViewController cursorsVar] canvasBoundsVar:[IFVariableKVO variableWithKVOCompliantObject:self.document key:@"canvasBounds"]];
  
  NSArray* views = [[window contentView] subviews];
  NSAssert([views count] == 1, @"unexpected number of sub-views");
  NSSplitView* splitView = [views objectAtIndex:0];

  [splitView replaceSubview:[[splitView subviews] objectAtIndex:0] with:treeViewController.view];
  [splitView replaceSubview:[[splitView subviews] objectAtIndex:1] with:imageViewController.view];

  [treeViewController setDocument:self.document];
}

- (void)windowDidLoad;
{  
  [hudWindowController setCursorPair:treeViewController.cursorsVar.value];
  [hudWindowController setUnderlyingWindow:self.window];
  [hudWindowController setUnderlyingView:imageViewController.activeView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFActiveViewDidChange) {
    [hudWindowController setUnderlyingView:imageViewController.activeView];
  } else if (context == IFImageViewModeDidChange) {
    [hudWindowController setVisible:([imageViewController mode] == IFImageViewModeEdit)];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

@end
