//
//  IFProbeWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 19.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFProbeWindowController.h"
#import "IFDocument.h"
#import "IFTreeView.h"

@implementation IFProbeWindowController

static NSDictionary* stringToInt;

+ (void)initialize;
{
  if (self != [IFProbeWindowController class])
    return; // avoid repeated initialisation

  stringToInt = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithInt:0], @"0",
    [NSNumber numberWithInt:1], @"1",
    [NSNumber numberWithInt:2], @"2",
    [NSNumber numberWithInt:3], @"3",
    [NSNumber numberWithInt:4], @"4",
    [NSNumber numberWithInt:5], @"5",
    [NSNumber numberWithInt:6], @"6",
    [NSNumber numberWithInt:7], @"7",
    [NSNumber numberWithInt:8], @"8",
    [NSNumber numberWithInt:9], @"9",
    nil];
  [stringToInt retain];
}

- (id)initWithWindow:(NSWindow*)window;
{
  if (![super initWithWindow:window])
    return nil;
  probe = [[IFProbe alloc] initWithMark:nil];
  marks = nil;
  markIndex = previousMarkIndex = 0;
  keyDownEventTimeStamp = 0;
  return self;
}

- (void)windowDidLoad;
{
  [super windowDidLoad];
  [[self window] setDelegate:self];
  [[self window] registerForDraggedTypes:[NSArray arrayWithObject:IFMarkPboardType]];
}

- (void) dealloc {
  [[self window] setDelegate:nil];
  OBJC_RELEASE(probe);
  [super dealloc];
}

- (void)documentDidChange:(IFDocument*)newDocument;
{
  if (newDocument != nil) {
    [self stickToBookmarkIndex:markIndex];
  } else {
    [probe setMark:nil];
  }  
}

- (void)stickToBookmarkIndex:(int)index;
{
  previousMarkIndex = markIndex;
  markIndex = index;
  [probe setMark:[marks objectAtIndex:markIndex]];
  [[self window] setTitle:[[probe mark] tag]];
}

- (IBAction)stickToBookmark:(id)sender;
{
  NSMenuItem* item = sender;
  [self stickToBookmarkIndex:[item tag]];
}

- (NSArray*)marks;
{
  return [marks copy];
}

- (BOOL)validateMenuItem:(NSMenuItem*)item;
{
  if ([item action] == @selector(stickToBookmark:))
    return [[marks objectAtIndex:[item tag]] isSet];
  else
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent;
{
  if (keyDownEventTimeStamp == 0) {
    NSNumber* boxedMarkIndex = [stringToInt objectForKey:[theEvent characters]];
    if (boxedMarkIndex != nil) {
      keyDownEventTimeStamp = [theEvent timestamp];
      [self stickToBookmarkIndex:[boxedMarkIndex intValue]];
    }
  }
}

- (void)keyUp:(NSEvent*)theEvent;
{
  if (keyDownEventTimeStamp == 0)
    return;

  NSTimeInterval downTime = [theEvent timestamp] - keyDownEventTimeStamp;
  if (downTime > 0.1)
    [self stickToBookmarkIndex:previousMarkIndex];
  keyDownEventTimeStamp = 0;
}

#pragma mark Drag and drop

static BOOL dragOk;

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;
{
  NSArray* types = [[sender draggingPasteboard] types];
  dragOk = [types containsObject:IFMarkPboardType];
  return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender;
{
  return dragOk ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
{
  if (!dragOk)
    return NO;

  NSPasteboard* pboard = [sender draggingPasteboard];
  int index = [(NSNumber*)[NSUnarchiver unarchiveObjectWithData:[pboard dataForType:IFMarkPboardType]] intValue];
  [self stickToBookmarkIndex:index];
  return YES;
}

@end
