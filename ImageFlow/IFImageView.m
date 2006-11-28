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
#import "IFAnnotation.h"
#import "IFCursorRect.h"
#import "IFUtilities.h"

typedef enum {
  IFImageViewDelegateHasHandleMouseDown    = (1<<0),
  IFImageViewDelegateHasHandleMouseDragged = (1<<1),
  IFImageViewDelegateHasHandleMouseUp      = (1<<2)
} IFImageViewDelegateCapabilities;

@interface IFImageView (Private)
- (NSRect)marginRect;
- (void)updateBounds;
@end

@implementation IFImageView

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame])
    return nil;
  
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];

  image = nil;
  annotations = nil;
  
  marginDirection = IFDown;
  desiredMarginSize = actualMarginSize = 0.0;
  marginColor = [[NSColor blackColor] retain];
  
  delegate = nil;
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(marginColor);
  [self setAnnotations:nil];
  [self setImage:nil dirtyRect:NSZeroRect];
  
  OBJC_RELEASE(grabableViewMixin);
  
  [super dealloc];
}

- (void)setCanvasBounds:(NSRect)newCanvasBounds;
{
  if (NSEqualRects(canvasBounds,newCanvasBounds))
    return;

  canvasBounds = newCanvasBounds;
  [self updateBounds];
  [self setNeedsDisplay:YES]; // TODO refine
}

- (void)setImage:(IFImage*)newImage dirtyRect:(NSRect)dirtyRect;
{
  if (newImage == image)
    return;
  [image release];
  image = [newImage retain];
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

- (void)setMarginDirection:(IFDirection)newMarginDirection;
{
  if (newMarginDirection == marginDirection)
    return;

  [self setNeedsDisplayInRect:[self marginRect]];
  marginDirection = newMarginDirection;
  [self updateBounds];
  [self setNeedsDisplayInRect:[self marginRect]];
}

- (IFDirection)marginDirection;
{
  return marginDirection;
}

- (void)setMarginSize:(float)newMarginSize;
{
  if (newMarginSize == desiredMarginSize)
    return;

  NSRect visibleMarginRect = NSIntersectionRect([self visibleRect],[self marginRect]);
  float visibleMarginSize = (marginDirection == IFUp || marginDirection == IFDown)
    ? NSHeight(visibleMarginRect)
    : NSWidth(visibleMarginRect);

  [self setNeedsDisplayInRect:[self marginRect]];
  desiredMarginSize = newMarginSize;
  actualMarginSize = fmax(desiredMarginSize, visibleMarginSize);
  [self updateBounds];
  [self setNeedsDisplayInRect:[self marginRect]];
}

- (float)marginSize;
{
  return desiredMarginSize;
}

- (void)setMarginColor:(NSColor*)newMarginColor;
{
  if (newMarginColor == marginColor)
    return;
  [marginColor release];
  marginColor = [newMarginColor retain];

  [self setNeedsDisplayInRect:[self marginRect]];
}

- (NSColor*)marginColor;
{
  return marginColor;
}

- (void)drawRect:(NSRect)dirtyRect;
{
  if (image == nil) {
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    return;
  }

  CIContext* ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                           options:[NSDictionary dictionary]]; // TODO working color space
  CGRect dirtyRectCG = CGRectFromNSRect(dirtyRect);
  [ctx drawImage:[image imageCI] atPoint:dirtyRectCG.origin fromRect:dirtyRectCG];
  
  // Draw annotations
  const int annotationsCount = [annotations count];
  for (int i = 0; i < annotationsCount; ++i)
    [[annotations objectAtIndex:i] drawForRect:dirtyRect];
  
  // Draw margin
  NSRect marginRect = [self marginRect];
  if (!NSEqualRects(marginRect,NSZeroRect) && NSIntersectsRect(dirtyRect,marginRect)) {
    [marginColor set];
    [NSBezierPath fillRect:marginRect];
  }
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

- (BOOL)acceptsFirstMouse:(NSEvent*)event;
{
  return YES;
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

- (NSRect)marginRect;
{
  if (actualMarginSize == 0)
    return NSZeroRect;
  
  switch (marginDirection) {
    case IFUp:
      return NSMakeRect(NSMinX(canvasBounds),NSMaxY(canvasBounds),NSWidth(canvasBounds),actualMarginSize);
    case IFRight:
      return NSMakeRect(NSMaxX(canvasBounds),NSMinY(canvasBounds),actualMarginSize,NSHeight(canvasBounds));
    case IFDown:
      return NSMakeRect(NSMinX(canvasBounds),NSMinY(canvasBounds) - actualMarginSize,NSWidth(canvasBounds),actualMarginSize);
    case IFLeft:
      return NSMakeRect(NSMinX(canvasBounds) - actualMarginSize,NSMinY(canvasBounds),actualMarginSize,NSHeight(canvasBounds));
    default:
      NSAssert(NO, @"internal error");
      return NSZeroRect;
  }
}

- (void)updateBounds;
{
  NSRect bounds = NSUnionRect(canvasBounds,[self marginRect]);

  NSPoint visibleOrigin = [self visibleRect].origin;
  [self setBoundsOrigin:bounds.origin];
  NSScrollView* scrollView = [self enclosingScrollView];
  if (scrollView != nil) {    
    [[scrollView horizontalRulerView] setOriginOffset:-NSMinX(bounds)];
    [[scrollView verticalRulerView] setOriginOffset:-NSMinY(bounds)];
  }
  [self setFrameSize:bounds.size];
  [self scrollPoint:visibleOrigin];
}

@end
