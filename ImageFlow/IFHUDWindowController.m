//
//  IFHUDWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFHUDWindowController.h"

@interface IFHUDWindowController (Private)
- (void)underlyingWindowDidResize:(NSNotification*)notification;
- (void)stackingViewDidResize:(NSNotification*)notification;
- (void)updateWindowFrame;
@end

@implementation IFHUDWindowController

- (id)init;
{
  if (![super initWithWindowNibName:@"IFHUDWindow"])
    return nil;
  filterSettingsViewController = [IFFilterSettingsViewController new];
  underlyingView = nil;
  underlyingWindow = nil;
  return self;
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  OBJC_RELEASE(underlyingWindow);
  OBJC_RELEASE(underlyingView);
  OBJC_RELEASE(filterSettingsViewController);
  [super dealloc];
}

- (void)awakeFromNib;
{
  NSWindow* window = [self window];
  [window setOpaque:NO];
  [window setBackgroundColor:[[NSColor whiteColor] colorWithAlphaComponent:0.8]];
  [window setHasShadow:NO];
  [window setDisplaysWhenScreenProfileChanges:YES];
  
  [stackingView addSubview:filterSettingsViewController.view];

  NSAssert([stackingView postsFrameChangedNotifications] , @"incorrectly configured view");
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(stackingViewDidResize:)
                                               name:NSViewFrameDidChangeNotification
                                             object:stackingView];
  
  [self updateWindowFrame];
}

- (void)setUnderlyingWindow:(NSWindow*)newUnderlyingWindow;
{
  if (newUnderlyingWindow == underlyingWindow)
    return;
  
  if (underlyingWindow != nil) {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:underlyingWindow];
    [underlyingWindow release];
  }
  if (newUnderlyingWindow != nil) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underlyingWindowDidResize:) name:NSWindowDidResizeNotification object:newUnderlyingWindow];
    [newUnderlyingWindow retain];
  }
  underlyingWindow = newUnderlyingWindow;

}

- (void)setUnderlyingView:(NSView*)newUnderlyingView;
{
  if (newUnderlyingView == underlyingView)
    return;
  [underlyingView release];
  underlyingView = [newUnderlyingView retain];
  
  [self updateWindowFrame];
}

- (void)setCursorPair:(IFTreeCursorPair*)newCursors;
{
  [filterSettingsViewController setCursorPair:newCursors];
}

- (void)setVisible:(BOOL)shouldBeVisible;
{
  NSWindow* window = [self window];
  if (shouldBeVisible && ![window isVisible]) {
    [self updateWindowFrame];
    [underlyingWindow addChildWindow:window ordered:NSWindowAbove];
    [window orderFront:nil];
  } else if (!shouldBeVisible && [window isVisible]) {
    [underlyingWindow removeChildWindow:window];
    [window orderOut:nil];
  }
}

- (IFFilterSettingsViewController*)filterSettingsViewController;
{
  return filterSettingsViewController;
}

@end

@implementation IFHUDWindowController (Private)

- (void)underlyingWindowDidResize:(NSNotification*)notification;
{
  [self updateWindowFrame];
}

- (void)stackingViewDidResize:(NSNotification*)notification;
{
  [self updateWindowFrame];
}

- (void)updateWindowFrame;
{
  NSSize idealSize = [stackingView frame].size;
  NSSize finalSize = NSMakeSize(idealSize.width, idealSize.height + 25);
  NSSize maxSize = [underlyingView visibleRect].size;
  
  BOOL hScroller = NO, vScroller = NO;
  if (finalSize.width > maxSize.width) {
    finalSize.width = maxSize.width;
    hScroller = YES;
    finalSize.height += [NSScroller scrollerWidthForControlSize:NSSmallControlSize];
  }
  if (finalSize.height > maxSize.height) {
    finalSize.height = maxSize.height;
    vScroller = YES;
    finalSize.width += [NSScroller scrollerWidthForControlSize:NSSmallControlSize];
  }
  if (finalSize.width > maxSize.width) {
    NSAssert(vScroller, @"internal error");
    finalSize.width = maxSize.width;
    hScroller = YES;
  }
  
  NSScrollView* scrollView = [stackingView enclosingScrollView];
  [scrollView setHasHorizontalScroller:hScroller];
  [scrollView setHasVerticalScroller:vScroller];
  
  NSPoint referenceOrigin = [underlyingView isFlipped]
    ? NSMakePoint(NSMinX([underlyingView visibleRect]),NSMaxY([underlyingView visibleRect]))
    : [underlyingView visibleRect].origin;
  NSPoint screenVisibleOrigin = [underlyingWindow convertBaseToScreen:[underlyingView convertPoint:referenceOrigin toView:nil]];
  screenVisibleOrigin.x += 1;
  screenVisibleOrigin.y += 1;

  NSRect newFrame = { screenVisibleOrigin, finalSize };
  [[self window] setFrame:newFrame display:YES];
}

@end
