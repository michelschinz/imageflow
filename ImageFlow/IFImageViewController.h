//
//  IFImageViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFViewController.h"
#import "IFImageView.h"
#import "IFTreeNode.h"
#import "IFExpressionEvaluator.h"
#import "IFTreeCursorPair.h"

typedef enum {
  IFImageViewModeView,
  IFImageViewModeEdit,
} IFImageViewMode;

@interface IFImageViewController : IFViewController<IFImageViewDelegate> {
  IBOutlet NSTabView* imageOrErrorTabView;
  IBOutlet IFImageView* imageView;
  NSView* activeView; // not retained, either imageOrErrorTabView or imageView

  IFImageViewMode mode;

  IFExpressionEvaluator* evaluator;
  IFExpression* expression;
  NSString* errorMessage;
  NSAffineTransform* editViewTransform;
  NSAffineTransform* viewEditTransform;
  NSArray* variants;
  NSString* activeVariant;
  
  IFTreeCursorPair* cursors;
  IFTreeNode* viewedNode;

  NSRect canvasBounds;
  float marginSize;
  IFDirection marginDirection;
  
  NSObject<IFFilterDelegate>* filterDelegate;
  unsigned filterDelegateCapabilities;
}

- (IFImageView*)imageView;
- (NSView*)activeView;

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;

- (void)setCursorPair:(IFTreeCursorPair*)newCursors;
- (IFTreeCursorPair*)cursorPair;

- (void)setMode:(IFImageViewMode)newMode;
- (IFImageViewMode)mode;

- (void)setCanvasBounds:(NSRect)newCanvasBounds;
- (void)setMarginSize:(float)newMarginSize;
- (float)marginSize;
- (void)setMarginDirection:(IFDirection)newDirection;
- (IFDirection)marginDirection;

- (NSString*)errorMessage;

- (NSArray*)variants;
- (void)setVariants:(NSArray*)newVariants;
- (NSString*)activeVariant;
- (void)setActiveVariant:(NSString*)newActiveVariant;

@end
