//
//  IFTreeViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreePaletteViewController.h"

@implementation IFTreePaletteViewController

+ (void)initialize {
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

- (void)awakeFromNib;
{
  cursorsVar.value = treeView.cursors;
}

- (void)setDocument:(IFDocument*)document;
{
  [treeView setDocument:document];
  [paletteView setDocument:document];
}

@synthesize cursorsVar;

- (void)willBecomeActive:(IFNodesView*)nodesView;
{
  cursorsVar.value = nodesView.cursors;
}

@end
