//
//  IFImageView.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFGrabableViewMixin.h"
#import "IFExpressionEvaluator.h"
#import "IFExpression.h"
#import "IFImageConstantExpression.h"

@protocol IFImageViewDelegate
- (void)handleMouseDown:(NSEvent*)event;
- (void)handleMouseDragged:(NSEvent*)event;
- (void)handleMouseUp:(NSEvent*)event;
@end

@interface IFImageView : NSView {
  IFGrabableViewMixin* grabableViewMixin;

  CIImage* backgroundImage;
  CIFilter* backgroundCompositingFilter;
  IFExpressionEvaluator* evaluator;
  IFExpression* expression;
  NSArray* annotations;
  NSObject<IFImageViewDelegate>* delegate;
  unsigned delegateCapabilities;
  
  IFImageConstantExpression* evaluatedExpression;
  BOOL infiniteBoundsMode;
}

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
- (void)setExpression:(IFExpression*)newExpression;

- (void)setAnnotations:(NSArray*)newAnnotations;
- (void)setDelegate:(NSObject<IFImageViewDelegate>*)newDelegate;

- (NSSize)idealSize;

- (void)enterInfiniteBoundsMode;
- (void)leaveInfiniteBoundsMode;
- (BOOL)inInfiniteBoundsMode;

@end
