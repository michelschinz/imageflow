//
//  IFImageView.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFExpression.h"
#import "IFExpressionEvaluator.h"
#import "IFImage.h"
#import "IFUtilities.h"

@protocol IFImageViewDelegate
- (void)handleMouseDown:(NSEvent*)event;
- (void)handleMouseDragged:(NSEvent*)event;
- (void)handleMouseUp:(NSEvent*)event;
@end

@interface IFImageView : NSView {
  IFGrabableViewMixin* grabableViewMixin;

  NSRect canvasBounds;
  IFImage* image;
  NSArray* annotations;

  IFDirection marginDirection;
  float desiredMarginSize, actualMarginSize;
  NSColor* marginColor;
  
  NSObject<IFImageViewDelegate>* delegate;
  unsigned delegateCapabilities;
}

- (void)setCanvasBounds:(NSRect)newCanvasBounds;
- (void)setImage:(IFImage*)newImage dirtyRect:(NSRect)dirtyRect;

- (void)setAnnotations:(NSArray*)newAnnotations;
- (void)setDelegate:(NSObject<IFImageViewDelegate>*)newDelegate;

- (void)setMarginDirection:(IFDirection)newMarginDirection;
- (IFDirection)marginDirection;
- (void)setMarginSize:(float)newMarginSize;
- (float)marginSize;
- (void)setMarginColor:(NSColor*)newMarginColor;
- (NSColor*)marginColor;

@end
