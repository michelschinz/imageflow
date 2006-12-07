//
//  IFAnnotationRect.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFAnnotationRect.h"
#import "IFCursorRect.h"
#import "NSAffineTransformIFAdditions.h"
#import "IFCursorRepository.h"
#import "IFUtilities.h"

@implementation IFAnnotationRect

+ (id)annotationRectWithView:(NSView*)theView source:(IFVariable*)theSource;
{
  return [[[self alloc] initWithView:theView source:theSource] autorelease];
}

- (id)initWithView:(NSView*)theView source:(IFVariable*)theSource;
{
  if (![super initWithView:theView source:theSource])
    return nil;
  lineColor = [[NSColor whiteColor] retain];
  lineWidth = 1.0;
  canBeDragged = canBeResized = YES;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(lineColor);
  [super dealloc];
}

- (float)lineWidth;
{
  return lineWidth;
}

- (void)setLineWidth:(float)newLineWidth;
{
  lineWidth = newLineWidth;
}

- (NSColor*)lineColor;
{
  return lineColor;
}

- (void)setLineColor:(NSColor*)newLineColor;
{
  if (newLineColor == lineColor)
    return;
  [lineColor release];
  lineColor = [newLineColor retain];
}

- (BOOL)canBeDragged;
{
  return canBeDragged;
}

- (void)setCanBeDragged:(BOOL)newCanBeDragged;
{
  canBeDragged = newCanBeDragged;
}

- (BOOL)canBeResized;
{
  return canBeResized;
}

- (void)setCanBeResized:(BOOL)newCanBeResized;
{
  canBeResized = newCanBeResized;
}

- (void)drawForRect:(NSRect)dirtyRect;
{
  NSRect rect = [(NSValue*)[[self source] value] rectValue];
  NSBezierPath* path = [[self transform] transformBezierPath:[NSBezierPath bezierPathWithRect:NSInsetRect(rect,-0.5,-0.5)]];
  [path setLineWidth:lineWidth];
  [lineColor set];
  [path stroke];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
  NSRect oldRect = (oldValue == [NSNull null]) ? NSZeroRect : NSInsetRect([oldValue rectValue], -1, -1);
  id newValue = [change valueForKey:NSKeyValueChangeNewKey];
  NSRect newRect = (oldValue == [NSNull null]) ? NSZeroRect : NSInsetRect([newValue rectValue], -1, -1);
  [view setNeedsDisplayInRect:[[self transform] transformRect:oldRect]];
  [view setNeedsDisplayInRect:[[self transform] transformRect:newRect]];
  [[view window] invalidateCursorRectsForView:view];
}

- (NSArray*)cursorRects;
{
  // TODO handle transform
  if (!canBeDragged)
    return [NSArray array];

  NSRect rect = [(NSValue*)[[self source] value] rectValue];
  return [NSArray arrayWithObject:[IFCursorRect cursor:[[IFCursorRepository sharedRepository] moveCursor] rect:rect]];
}

- (bool)handleMouseDown:(NSEvent*)event;
{
  if (!canBeDragged)
    return NO;

  NSPoint pos = [[self inverseTransform] transformPoint:[[self view] convertPoint:[event locationInWindow] fromView:nil]];
  NSRect rect = [(NSValue*)[[self source] value] rectValue];
  if (!NSMouseInRect(pos,rect,NO))
    return NO;

  for (;;) {
    NSEvent* event = [[view window] nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask];

    switch ([event type]) {
      case NSLeftMouseDragged: {
        NSRect rect = [(NSValue*)[[self source] value] rectValue];
        NSSize delta = [[self inverseTransform] transformSize:NSMakeSize([event deltaX],-[event deltaY])];
        [[self source] setValue:[NSValue valueWithRect:NSOffsetRect(rect,delta.width,delta.height)]];
      } break;

      case NSLeftMouseUp:
        return YES;

      default:
        NSAssert1(NO, @"unexpected event type (%@)",event);
        break;
    }
  }
}

@end
