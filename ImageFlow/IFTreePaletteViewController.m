//
//  IFTreeViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreePaletteViewController.h"

#import "IFLayoutParameters.h"
#import "IFVariableKVO.h"

@implementation IFTreePaletteViewController

+ (void)initialize;
{
  if (self != [IFTreePaletteViewController class])
    return; // avoid repeated initialisation

  [self setKeys:[NSArray arrayWithObject:@"activeView"] triggerChangeNotificationsForDependentKey:@"cursors"];
}

- (id)init;
{
  if (![super initWithViewNibName:@"IFTreeView"])
    return nil;
  cursorsVar = [IFVariable variable];
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(cursorsVar);
  [super dealloc];
}

- (void)awakeFromNib;
{
  layoutParametersController.content = [IFLayoutParameters sharedLayoutParameters];
  cursorsVar.value = forestView.cursors;
}

@synthesize document;

- (void)setDocument:(IFDocument*)newDocument;
{
  if (newDocument == document)
    return;
  
  [document release];
  document = [newDocument retain];

  [forestView setDocument:newDocument];
//  [paletteView setDocument:document];
}

@synthesize cursorsVar;

// MARK: delegate methods

- (void)willBecomeActive:(IFForestView*)newForestView; // TODO: see how to integrate the palette here (which type to use? two different notification methods?)
{
  cursorsVar.value = newForestView.cursors;
}

- (void)beginPreviewForNode:(IFTreeNode*)node ofTree:(IFTree*)tree;
{
  IFVariable* canvasBoundsVar = [IFVariableKVO variableWithKVOCompliantObject:document key:@"canvasBounds"];
  [paletteView switchToPreviewModeForNode:node ofTree:tree canvasBounds:canvasBoundsVar];
}

- (void)endPreview;
{
  [paletteView switchToNormalMode];
}

@end
