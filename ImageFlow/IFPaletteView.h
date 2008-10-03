//
//  IFPaletteView.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFForestView.h"
#import "IFPaletteLayoutManager.h"

@interface IFPaletteView : NSView<IFPaletteLayoutManagerDelegate> {
  IFGrabableViewMixin* grabableViewMixin;

  // Cursors & selection
  IFTreeCursorPair* cursors;

  // Templates
  NSMutableArray* templates;
  NSArray* normalModeTrees;
  
  // First responder
  BOOL acceptFirstResponder;
  
  // Delegate
  id<IFForestViewDelegate> delegate;
}

@property(assign) id<IFForestViewDelegate> delegate;

@end
