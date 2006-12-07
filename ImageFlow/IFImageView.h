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
#import "IFAnnotationRect.h"
#import "IFVariable.h"
#import "IFUtilities.h"

@protocol IFImageViewDelegate
- (void)handleMouseDown:(NSEvent*)event;
- (void)handleMouseDragged:(NSEvent*)event;
- (void)handleMouseUp:(NSEvent*)event;
@end

@interface IFImageView : NSView {
  IFGrabableViewMixin* grabableViewMixin;

  NSRect visibleBounds;
  IFImage* image;
  IFAnnotationRect* canvasBoundsAnnotation;
  NSArray* annotations;

  NSObject<IFImageViewDelegate>* delegate;
  unsigned delegateCapabilities;
}

- (void)setVisibleBounds:(NSRect)newVisibleBounds;
- (void)setCanvasBounds:(IFVariable*)newCanvasBounds;
- (void)setImage:(IFImage*)newImage dirtyRect:(NSRect)dirtyRect;
- (void)setAnnotations:(NSArray*)newAnnotations;
- (void)setDelegate:(NSObject<IFImageViewDelegate>*)newDelegate;

@end
