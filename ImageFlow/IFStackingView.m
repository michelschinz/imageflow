//
//  IFStackingView.m
//  ImageFlow
//
//  Created by Michel Schinz on 20.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFStackingView.h"

@interface IFStackingView (Private)
- (void)viewFrameDidChange:(NSNotification*)notification;
- (void)updateLayout;
@end

@implementation IFStackingView

- (id)initWithFrame:(NSRect)frameRect;
{
  if (![super initWithFrame:frameRect])
    return nil;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:nil];
  return self;
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)addSubview:(NSView*)subView;
{
  NSAssert([subView postsFrameChangedNotifications], @"subview doesn't post frame change notifications");
  [super addSubview:subView];
  [self updateLayout];
}

- (void)addSubview:(NSView*)subView positioned:(NSWindowOrderingMode)place relativeTo:(NSView*)otherView;
{
  NSAssert([subView postsFrameChangedNotifications], @"subview doesn't post frame change notifications");
  [super addSubview:subView positioned:place relativeTo:otherView];
  [self updateLayout];
}

- (void)willRemoveSubview:(NSView*)subview;
{
  [super willRemoveSubview:subview];
  [self updateLayout];
}

@end

@implementation IFStackingView (Private)

- (void)viewFrameDidChange:(NSNotification*)notification;
{
  NSView* view = [notification object];
  if (![[self subviews] containsObject:view])
    return;
  [self updateLayout];
}

const float minHeight = 0.0;
const float xMargin = 12.0;

- (void)updateLayout;
{
  NSArray* subViews = [self subviews];

  float maxHeight = minHeight;
  float x = xMargin, y = 0.0;
  for (int i = 0; i < [subViews count]; ++i) {
    NSPoint origin = NSMakePoint(x,y);
    NSView* view = [subViews objectAtIndex:i];
    NSRect frame = [view frame];
    if (!NSEqualPoints(frame.origin, origin)) {
      [view setFrameOrigin:origin];
      [self setNeedsDisplay:YES];
    }
    x += NSWidth(frame) + xMargin;
    maxHeight = fmax(maxHeight,NSHeight(frame));
  }
  [self setFrameSize:NSMakeSize(x,maxHeight)];
  [self setNeedsDisplay:YES];
}

@end
