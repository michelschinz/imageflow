//
//  IFImageView.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageView.h"
#import "IFImageConstantExpression.h"
#import "IFOperatorExpression.h"
#import "IFUtilities.h"
#import "IFAnnotation.h"
#import "IFCursorRect.h"

typedef enum {
  IFImageViewDelegateHasHandleMouseDown    = (1<<0),
  IFImageViewDelegateHasHandleMouseDragged = (1<<1),
  IFImageViewDelegateHasHandleMouseUp      = (1<<2)
} IFImageViewDelegateCapabilities;

@interface IFImageView (Private)
- (IFImageConstantExpression*)evaluatedExpression;
- (void)setEvaluatedExpression:(IFImageConstantExpression*)newEvaluatedExpression;
@end

@implementation IFImageView

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame])
    return nil;
  
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  
  evaluator = nil;
  expression = nil;
  annotations = nil;
  delegate = nil;
  return self;
}

- (void) dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [self setEvaluator:nil];
  [self setEvaluatedExpression:nil];
  [self setAnnotations:nil];
  [expression release];
  expression = nil;
  
  [grabableViewMixin release];
  grabableViewMixin = nil;
  
  [super dealloc];
}

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
{
  if (newEvaluator == evaluator)
    return;

  if (evaluator != nil) {
    [evaluator removeObserver:self forKeyPath:@"workingColorSpace"];
    [evaluator removeObserver:self forKeyPath:@"resolutionX"];
    [evaluator removeObserver:self forKeyPath:@"resolutionY"];
  }    
  evaluator = newEvaluator;
  if (evaluator != nil) {
    [evaluator addObserver:self forKeyPath:@"workingColorSpace" options:0 context:nil];
    [evaluator addObserver:self forKeyPath:@"resolutionX" options:0 context:nil];
    [evaluator addObserver:self forKeyPath:@"resolutionY" options:0 context:nil];
  }  
  [self setNeedsDisplay:YES];
}

- (void)setCanvasBounds:(NSRect)newCanvasBounds;
{
  if (NSEqualRects(canvasBounds,newCanvasBounds))
    return;

  canvasBounds = newCanvasBounds;
  
  NSPoint visibleOrigin = [self visibleRect].origin;
  [self setBoundsOrigin:canvasBounds.origin];
  NSScrollView* scrollView = [self enclosingScrollView];
  if (scrollView != nil) {    
    [[scrollView horizontalRulerView] setOriginOffset:-NSMinX(canvasBounds)];
    [[scrollView verticalRulerView] setOriginOffset:-NSMinY(canvasBounds)];
  }
  [self setFrameSize:canvasBounds.size];
  [self scrollPoint:visibleOrigin];
  [self setNeedsDisplay:YES];
}

- (void)setExpression:(IFExpression*)newExpression;
{
  if (newExpression == expression)
    return;
  
  NSRect dirtyRect = (expression == nil || newExpression == nil)
    ? NSRectInfinite()
    : [evaluator deltaFromOld:expression toNew:newExpression];
  [expression release];
  expression = [newExpression retain];
  
  [self setEvaluatedExpression:nil];
  [self setNeedsDisplayInRect:dirtyRect];
}

- (void)setAnnotations:(NSArray*)newAnnotations;
{
  if (newAnnotations == annotations)
    return;
  [annotations release];
  annotations = [newAnnotations copy];
  
  [self setNeedsDisplay:YES];
  [[self window] invalidateCursorRectsForView:self];
}

- (void)setDelegate:(NSObject<IFImageViewDelegate>*)newDelegate;
{
  delegate = newDelegate;
  delegateCapabilities = 0
    | ([delegate respondsToSelector:@selector(handleMouseDown:)] ? IFImageViewDelegateHasHandleMouseDown : 0)
    | ([delegate respondsToSelector:@selector(handleMouseDragged:)] ? IFImageViewDelegateHasHandleMouseDragged : 0)
    | ([delegate respondsToSelector:@selector(handleMouseUp:)] ? IFImageViewDelegateHasHandleMouseUp : 0);
}

- (NSSize)idealSize;
{
  return expressionExtent.size;
}

- (void)drawRect:(NSRect)dirtyRect;
{
  IFImageConstantExpression* imageExpr = [self evaluatedExpression];
  if (imageExpr == nil || [imageExpr isError]) {
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    return;
  }

  CIContext* ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                           options:[NSDictionary dictionary]]; // TODO working color space
  CGRect dirtyRectCG = CGRectFromNSRect(dirtyRect);
  [ctx drawImage:[imageExpr imageValueCI] atPoint:dirtyRectCG.origin fromRect:dirtyRectCG];
  
  // Draw annotations
  const int annotationsCount = [annotations count];
  for (int i = 0; i < annotationsCount; ++i)
    [[annotations objectAtIndex:i] drawForRect:dirtyRect];
}

- (void)resetCursorRects;
{
  NSRect visibleRect = [self visibleRect];
  for (int i = 0; i < [annotations count]; ++i) {
    NSArray* cursorRects = [[annotations objectAtIndex:i] cursorRects];
    for (int j = 0; j < [cursorRects count]; ++j) {
      IFCursorRect* cursorRect = [cursorRects objectAtIndex:j];
      [self addCursorRect:NSIntersectionRect(visibleRect,[cursorRect rect]) cursor:[cursorRect cursor]];
    }
  }  
}

- (BOOL)isOpaque;
{
  return YES;
}

- (BOOL)acceptsFirstResponder;
{
  return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
  [self setEvaluatedExpression:nil];
  [self setNeedsDisplay:YES];
}

#pragma mark event handling

- (void)mouseDown:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDown:event])
    return;
  
  for (int i = 0; i < [annotations count]; ++i)
    if ([(IFAnnotation*)[annotations objectAtIndex:i] handleMouseDown:event])
      return;
  if (delegateCapabilities & IFImageViewDelegateHasHandleMouseDown)
    [delegate handleMouseDown:event];
}

- (void)mouseUp:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseUp:event])
    return;

  for (int i = 0; i < [annotations count]; ++i)
    if ([(IFAnnotation*)[annotations objectAtIndex:i] handleMouseUp:event])
      break;
  if (delegateCapabilities & IFImageViewDelegateHasHandleMouseUp)
    [delegate handleMouseUp:event];
}

- (void)mouseDragged:(NSEvent*)event;
{
  if ([grabableViewMixin handlesMouseDragged:event])
    return;

  for (int i = 0; i < [annotations count]; ++i)
    if ([(IFAnnotation*)[annotations objectAtIndex:i] handleMouseDragged:event])
      break;
  if (delegateCapabilities & IFImageViewDelegateHasHandleMouseDragged)
    [delegate handleMouseDragged:event];
}

- (void)keyDown:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyDown:event])
    [super keyDown:event];
}

- (void)keyUp:(NSEvent*)event;
{
  if (![grabableViewMixin handlesKeyUp:event])
    [super keyUp:event];
}

@end

@implementation IFImageView (Private)

- (IFImageConstantExpression*)evaluatedExpression;
{
  if (expression == nil)
    return nil;

  if (evaluatedExpression == nil) {
    IFConstantExpression* extentExpr = [evaluator evaluateExpression:[IFOperatorExpression extentOf:expression]];
    if ([extentExpr isError]) {
      expressionExtent = NSZeroRect;
      [self setEvaluatedExpression:nil];
    } else {
      expressionExtent = [extentExpr rectValueNS];
      [self setEvaluatedExpression:(IFImageConstantExpression*)[evaluator evaluateExpressionAsImage:expression]];
    }
  }
  return evaluatedExpression;
}

- (void)setEvaluatedExpression:(IFImageConstantExpression*)newEvaluatedExpression;
{
  if (newEvaluatedExpression == evaluatedExpression)
    return;
  [evaluatedExpression release];
  evaluatedExpression = [newEvaluatedExpression retain];
}

@end
