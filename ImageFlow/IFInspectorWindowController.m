//
//  IFInspectorWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 05.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFInspectorWindowController.h"

@interface IFInspectorWindowController (Private)
- (void)setMainWindow:(NSWindow*)newMainWindow;
- (void)mainWindowDidChange:(NSNotification*)notification;
- (void)mainWindowDidResign:(NSNotification*)notification;
@end

@implementation IFInspectorWindowController

- (id)initWithWindow:(NSWindow*)window;
{
  if (![super initWithWindow:window])
    return nil;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowDidChange:)
                                               name:NSWindowDidBecomeMainNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowDidResign:)
                                               name:NSWindowDidResignMainNotification
                                             object:nil];
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)windowDidLoad;
{
  [super windowDidLoad];
  [(NSPanel*)[self window] setFloatingPanel:NO];
  [self setMainWindow:[NSApp mainWindow]];
}

- (void)documentDidChange:(IFDocument*)newDocument;
{
}

@end

@implementation IFInspectorWindowController (Private)

- (void)setMainWindow:(NSWindow*)newMainWindow;
{
  [self documentDidChange:[[newMainWindow windowController] document]];
}

- (void)mainWindowDidChange:(NSNotification*)notification;
{
  [self setMainWindow:[notification object]];
}

- (void)mainWindowDidResign:(NSNotification*)notification;
{
  [self setMainWindow:nil];
}

@end
