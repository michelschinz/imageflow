//
//  IFImageOrErrorViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImageView.h"
#import "IFTreeNode.h"
#import "IFExpressionEvaluator.h"
#import "IFTreeCursorPair.h"
#import "IFTree.h"

typedef enum {
  IFImageViewModeView,
  IFImageViewModeEdit,
} IFImageViewMode;

@interface IFImageOrErrorViewController : NSViewController<IFImageViewDelegate> {
  IBOutlet NSTabView* imageOrErrorTabView;
  IBOutlet IFImageView* imageView;
  NSView* activeView; // not retained, either imageOrErrorTabView or imageView

  IFImageViewMode mode;

  IFExpression* displayedExpression;
  NSString* errorMessage;
  NSArray* variants;
  NSString* activeVariant;
  
  IFVariable* cursorsVar;
  IFTreeNode* viewedNode;
  IFTreeNode* editedNode;

  IFVariable* canvasBoundsVar;
}

- (id)init;
- (void)postInitWithCursorsVar:(IFVariable*)theCursorsVar canvasBoundsVar:(IFVariable*)theCanvasBoundsVar;

@property(readonly, retain) IFImageView* imageView;
@property(readonly, assign) NSView* activeView;
@property IFImageViewMode mode;
@property(readonly, copy) NSString* errorMessage;
@property(copy) NSArray* variants;
@property(retain) NSString* activeVariant;

@end
