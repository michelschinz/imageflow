//
//  IFImageView.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageView.h"
#import "IFAnnotationRect.h"
#import "IFCursorRect.h"
#import "IFUtilities.h"

typedef enum {
  IFImageViewDelegateHasHandleMouseDown    = (1<<0),
  IFImageViewDelegateHasHandleMouseDragged = (1<<1),
  IFImageViewDelegateHasHandleMouseUp      = (1<<2)
} IFImageViewDelegateCapabilities;

@interface IFImageView (Private)
- (void)updateBounds;
@end

@implementation IFImageView

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame])
    return nil;
  grabableViewMixin = [[IFGrabableViewMixin alloc] initWithView:self];
  visibleBounds = NSZeroRect;
  image = nil;
  canvasBoundsAnnotation = nil;
  annotations = nil;
  delegate = nil;
  return self;
}

- (void)dealloc;
{
  delegate = nil;
  [self setAnnotations:nil];
  OBJC_RELEASE(canvasBoundsAnnotation);
  [self setImage:nil dirtyRect:NSZeroRect];
  OBJC_RELEASE(grabableViewMixin);
  [super dealloc];
}

- (void)setVisibleBounds:(NSRect)newVisibleBounds;
{
  if (NSEqualRects(newVisibleBounds,visibleBounds))
    return;
  visibleBounds = newVisibleBounds;
  [self updateBounds];
}

- (void)setCanvasBounds:(IFVariable*)newCanvasBounds;
{
  if (newCanvasBounds == [canvasBoundsAnnotation source])
    return;
  [canvasBoundsAnnotation release];
  canvasBoundsAnnotation = [[IFAnnotationRect annotationRectWithView:self source:newCanvasBounds] retain];
  [canvasBoundsAnnotation setCanBeDragged:NO];
  [canvasBoundsAnnotation setLineColor:[NSColor redColor]];
  [canvasBoundsAnnotation setLineWidth:2.0];
}

- (void)viewDidMoveToSuperview;
{
  [[self superview] setAutoresizesSubviews:YES];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self updateBounds];
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
  if (newAnnotations == nil)
    newAnnotations = [NSArray array];

  [annotations release];
  annotations = [[newAnnotations arrayByAddingObject:canvasBoundsAnnotation] retain];

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

- (void)drawRect:(NSRect)dirtyRect;
{
  if (image == nil) {
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    return;
  }

  CIContext* ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort]
                                           options:[NSDictionary dictionary]]; // TODO working color space
  CGRect dirtyRectCG = NSRectToCGRect(dirtyRect);
  [ctx drawImage:[image imageCI] atPoint:dirtyRectCG.origin fromRect:dirtyRectCG];

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

- (void)updateBounds;
{
  NSSize minSize = [[self superview] frame].size;
  NSSize finalSize = visibleBounds.size;
  NSPoint finalOrigin = visibleBounds.origin;

  if (minSize.width > finalSize.width) {
    finalOrigin.x -= floor((minSize.width - finalSize.width) / 2.0);
    finalSize.width = minSize.width;
  }
  if (minSize.height > finalSize.height) {
    finalOrigin.y -= floor((minSize.height - finalSize.height) / 2.0);
    finalSize.height = minSize.height;
  }

  NSPoint visibleOrigin = [self visibleRect].origin;
  [self setBoundsOrigin:finalOrigin];
  NSScrollView* scrollView = [self enclosingScrollView];
  if (scrollView != nil) {
    [[scrollView horizontalRulerView] setOriginOffset:-finalOrigin.x];
    [[scrollView verticalRulerView] setOriginOffset:-finalOrigin.y];
  }
  [self setFrameSize:finalSize];
  [self scrollPoint:visibleOrigin];

  [self setNeedsDisplay:YES]; // TODO refine
}

@end
