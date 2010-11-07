//
//  IFSavePanelController.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFSavePanelController.h"
#import "IFDirectoryManager.h"

@implementation IFSavePanelController

- (void)awakeFromNib;
{
  [(NSSavePanel*)savePanel setDelegate:self];
}

- (int)directoryIndex;
{
  return directoryIndex;
}

- (void)setDirectoryIndex:(int)newIndex;
{
  NSSavePanel* panel = (NSSavePanel*)savePanel;

  directoryIndex = newIndex;
  if (directoryIndex == 1)
    [panel setDirectory:[[IFDirectoryManager sharedDirectoryManager] documentTemplatesDirectory]];
}

- (void)panel:(id)sender directoryDidChange:(NSString *)path;
{
  [self setDirectoryIndex:0];
}

@end
