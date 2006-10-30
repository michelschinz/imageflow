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

@implementation IFAnnotationRect

+ (id)annotationRectWithView:(NSView*)theView source:(IFAnnotationSource*)theSource;
{
  return [[[self alloc] initWithView:theView source:theSource] autorelease];
}

- (void)drawForRect:(NSRect)dirtyRect;
{
  NSRect rect = [(NSValue*)[[self source] value] rectValue];
  NSBezierPath* path = [[self transform] transformBezierPath:[NSBezierPath bezierPathWithRect:NSInsetRect(rect,-0.5,-0.5)]];
  [[NSColor whiteColor] set];
  [path stroke];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSRect oldRect = NSInsetRect([(NSValue*)[change valueForKey:NSKeyValueChangeOldKey] rectValue], -1, -1);
  NSRect newRect = NSInsetRect([(NSValue*)[change valueForKey:NSKeyValueChangeNewKey] rectValue], -1, -1);
  [view setNeedsDisplayInRect:[[self transform] transformRect:oldRect]];
  [view setNeedsDisplayInRect:[[self transform] transformRect:newRect]];
  [[view window] invalidateCursorRectsForView:view];
}

- (NSArray*)cursorRects;
{
  // TODO handle transform
  NSRect rect = [(NSValue*)[[self source] value] rectValue];
  return [NSArray arrayWithObject:[IFCursorRect cursor:[[IFCursorRepository sharedRepository] moveCursor] rect:rect]];
}

- (bool)handleMouseDown:(NSEvent*)event;
{
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
        [[self source] updateValue:[NSValue valueWithRect:NSOffsetRect(rect,delta.width,delta.height)]];
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
