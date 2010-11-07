//
//  IFGrabableViewMixin.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFGrabableViewMixin.h"

typedef enum { Inactive, PrepareToGrab, Grab } IFGrabMode;

@interface IFGrabableViewMixin (Private)
- (void)gotoMode:(IFGrabMode)mode;
@end

@implementation IFGrabableViewMixin

- (id)initWithView:(NSView*)theView;
{
  if (![super init])
    return nil;
  view = theView; // not retained
  mode = Inactive;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowDidResignKey:)
                                               name:NSWindowDidResignKeyNotification
                                             object:[view window]];
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  view = nil;
  [super dealloc];
}

- (BOOL)isGrabbingActive;
{
  return (mode != Inactive);
}

- (BOOL)handlesKeyDown:(NSEvent*)event;
{
  if ([[event characters] isEqualToString:@" "]) {
    if (mode == Inactive)
      [self gotoMode:PrepareToGrab];
    return YES;
  } else
    return NO;
}

- (BOOL)handlesKeyUp:(NSEvent*)event;
{
  if ([[event characters] isEqualToString:@" "] && (mode != Inactive)) {
    [self gotoMode:Inactive];
    return YES;
  } else
    return NO;
}

- (BOOL)handlesMouseDown:(NSEvent*)event;
{
  if (mode == PrepareToGrab) {
    [self gotoMode:Grab];
    return YES;
  } else
    return NO;
}

- (BOOL)handlesMouseUp:(NSEvent*)event;
{
  if (mode == Grab) {
    [self gotoMode:PrepareToGrab];
    return YES;
  } else
    return NO;
}

- (BOOL)handlesMouseDragged:(NSEvent *)event;
{
  if (mode == Grab) {
    NSPoint currOrigin = [view visibleRect].origin;
    NSPoint newOrigin = NSMakePoint(currOrigin.x - [event deltaX], currOrigin.y + [event deltaY]);
    [view scrollPoint:newOrigin];
    return YES;
  } else
    return NO;
}

@end

@implementation IFGrabableViewMixin (Private)

- (void)gotoMode:(IFGrabMode)newMode;
{
  if (newMode == mode)
    return;

  if (mode < PrepareToGrab && newMode >= PrepareToGrab) {
    [[view window] disableCursorRects];
    [[NSCursor openHandCursor] push];
  }
  if (mode < Grab && newMode >= Grab)
    [[NSCursor closedHandCursor] push];
  if (mode >= Grab && newMode < Grab)
    [NSCursor pop];
  if (mode >= PrepareToGrab && newMode < PrepareToGrab) {
    [NSCursor pop];
    [[view window] enableCursorRects];
  }
  mode = newMode;
}

- (void)windowDidResignKey:(NSNotification*)notification;
{
  [self gotoMode:Inactive];
}

@end
