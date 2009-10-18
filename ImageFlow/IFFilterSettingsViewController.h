//
//  IFFilterSettingsViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeCursorPair.h"

@interface IFFilterSettingsViewController : NSViewController {
  IBOutlet NSTabView* tabView;
  
  IFTreeCursorPair* cursors;
  NSString* filterName;
  NSMutableDictionary* filterControllers;
  NSMutableDictionary* tabIndices;
  NSMutableDictionary* panelSizes;  
}

- (void)setCursorPair:(IFTreeCursorPair*)newCursors;

- (NSTabView*)tabView;
- (NSString*)filterName;

@end
