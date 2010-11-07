//
//  IFTreeViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreePaletteViewController.h"

#import "IFLayoutParameters.h"
#import "IFCompositeTreeCursorPair.h"
#import "IFVariableKVO.h"

@interface IFTreePaletteViewController ()
@property(retain) IFTreeTemplate* cachedSelectedTreeTemplate;
- (void)updateCursors;
@end

@implementation IFTreePaletteViewController

- (id)init;
{
  if (![super initWithNibName:@"IFTreeView" bundle:nil])
    return nil;
  cursorsVar = [[IFVariable variable] retain];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(cachedSelectedTreeTemplate);
  OBJC_RELEASE(cursorsVar);
  OBJC_RELEASE(document);
  [super dealloc];
}

- (void)awakeFromNib;
{
  cursorsVar.value = forestView.cursors;
}

@synthesize document;

- (void)setDocument:(IFDocument*)newDocument;
{
  if (newDocument == document)
    return;

  [document release];
  document = [newDocument retain];

  forestView.document = newDocument;
  paletteView.document = newDocument;
}

@synthesize cursorsVar;

// MARK: IFForestView delegate methods

- (void)forestViewWillBecomeActive:(IFForestView*)newForestView;
{
  cursorsVar.value = newForestView.cursors;
  [self updateCursors];
}

- (void)beginPreviewForNode:(IFTreeNode*)node ofTree:(IFTree*)tree;
{
  NSAssert(tree == document.tree, @"unexpected tree");
  [paletteView switchToPreviewModeForNode:node];
  cursorsVar.value = [IFCompositeTreeCursorPair compositeWithEditCursor:forestView.cursors viewCursor:paletteView.cursors];
  [self updateCursors];
}

- (void)previewFilterStringDidChange:(NSString*)newFilterString;
{
  paletteView.previewModeFilterString = newFilterString;
}

- (IFTreeTemplate*)selectedTreeTemplate;
{
  return cachedSelectedTreeTemplate;
}

- (BOOL)selectPreviousTreeTemplate;
{
  return [paletteView selectPreviousTreeTemplate];
}

- (BOOL)selectNextTreeTemplate;
{
  return [paletteView selectNextTreeTemplate];
}

- (void)endPreview;
{
  self.cachedSelectedTreeTemplate = paletteView.selectedTreeTemplate;

  cursorsVar.value = forestView.cursors;
  [self updateCursors];
  [paletteView switchToNormalMode];
  paletteView.previewModeFilterString = nil;
}

// MARK: IFPaletteView delegate methods

- (void)paletteViewWillBecomeActive:(IFPaletteView*)newPaletteView;
{
  cursorsVar.value = newPaletteView.cursors;
  [self updateCursors];
}

// MARK: -
// MARK: PRIVATE

@synthesize cachedSelectedTreeTemplate;

- (void)updateCursors;
{
  IFTreeCursorPair* cursors = cursorsVar.value;
  forestView.visualisedCursor = cursors;
  paletteView.visualisedCursor = cursors;
}

@end
