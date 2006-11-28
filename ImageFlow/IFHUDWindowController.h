//
//  IFHUDWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFFilterSettingsViewController.h"
#import "IFThumbnailViewController.h"
#import "IFTreeCursorPair.h"
#import "IFStackingView.h"

@interface IFHUDWindowController : NSWindowController {
  IBOutlet NSTextField* filterNameTextField;
  IBOutlet IFStackingView* stackingView;
  
  IFFilterSettingsViewController* filterSettingsViewController;
  IFThumbnailViewController* thumbnailViewController;
  NSView* underlyingView;
  NSWindow* underlyingWindow;
}

- (void)setUnderlyingWindow:(NSWindow*)newUnderlyingWindow;
- (void)setUnderlyingView:(NSView*)newUnderlyingView;

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
- (void)setCursorPair:(IFTreeCursorPair*)newCursors;

- (void)setVisible:(BOOL)shouldBeVisible;

- (IFFilterSettingsViewController*)filterSettingsViewController;
- (IFThumbnailViewController*)thumbnailViewController;

@end
