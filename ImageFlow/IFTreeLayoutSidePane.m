//
//  IFTreeLayoutSidePane.m
//  ImageFlow
//
//  Created by Michel Schinz on 16.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutSidePane.h"
#import "IFTreeView.h"

@interface IFTreeLayoutSidePane (Private)
- (NSRect)deleteButtonFrame;
@end

@implementation IFTreeLayoutSidePane

+ (id)layoutSidePaneWithBase:(IFTreeLayoutSingle*)theBase;
{
  return [[[self alloc] initWithBase:theBase] autorelease];
}

- (id)initWithBase:(IFTreeLayoutSingle*)theBase;
{
  if (![super initWithBase:theBase])
    return nil;
  [self setBounds:[[[containingView layoutStrategy] sidePanePath] bounds]];
  return self;
}

- (void)drawForLocalRect:(NSRect)rect;
{  
  IFTreeLayoutStrategy* strategy = [containingView layoutStrategy];

  [[[containingView layoutParameters] sidePaneColor] set];
  [[strategy sidePanePath] fill];
  
  const float buttonWidth = 11.0, buttonHeight = 11.0;
  const float xMargin = 2.0, yMargin = 2.0, yGap = 2.0;
  
  NSPoint origin = [self bounds].origin;
  menuButtonFrame = NSOffsetRect(NSMakeRect(xMargin, yMargin, buttonWidth, buttonHeight),origin.x,origin.y);
  NSButtonCell* menuButtonCell = [strategy menuButtonCell];
  [menuButtonCell drawWithFrame:menuButtonFrame inView:containingView];
  [menuButtonCell setRepresentedObject:[base node]];
  
  foldButtonFrame = NSOffsetRect(menuButtonFrame,0,buttonHeight + yGap);
  NSButtonCell* foldButtonCell = [strategy foldButtonCell];
  [foldButtonCell setState:[[base node] isFolded]];
  [foldButtonCell drawWithFrame:foldButtonFrame inView:containingView];
  [foldButtonCell setRepresentedObject:[base node]];

  deleteButtonFrame = NSOffsetRect(foldButtonFrame,0,buttonHeight + yGap);
  NSButtonCell* deleteButtonCell = [strategy deleteButtonCell];
  [deleteButtonCell drawWithFrame:deleteButtonFrame inView:containingView];
  [deleteButtonCell setRepresentedObject:[base node]];
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  NSPoint offset = [self translation];
  NSPoint localPoint = NSMakePoint(thePoint.x - offset.x, thePoint.y - offset.y);
  return NSPointInRect(localPoint, [self bounds]) && [[[containingView layoutStrategy] sidePanePath] containsPoint:localPoint] ? self : nil;
}

- (void)activateWithMouseDown:(NSEvent*)event;
{
  NSPoint viewLoc = [containingView convertPoint:[event locationInWindow] fromView:nil];
  NSPoint selfLoc = NSMakePoint(viewLoc.x - [self translation].x, viewLoc.y - [self translation].y);

  NSButtonCell* clickedCell = nil;
  if (NSPointInRect(selfLoc, deleteButtonFrame))
    clickedCell = [[containingView layoutStrategy] deleteButtonCell];
  else if (NSPointInRect(selfLoc, foldButtonFrame))
    clickedCell = [[containingView layoutStrategy] foldButtonCell];
  else if (NSPointInRect(selfLoc, menuButtonFrame))
    clickedCell = [[containingView layoutStrategy] menuButtonCell];

  if (clickedCell == nil)
    return;
  
  [clickedCell setHighlighted:YES];
  [self setNeedsDisplay];
  [clickedCell trackMouse:event inRect:[self frame] ofView:containingView untilMouseUp:NO];
  [clickedCell setHighlighted:NO];
  [self setNeedsDisplay];
}

@end

@implementation IFTreeLayoutSidePane (Private)

- (NSRect)deleteButtonFrame;
{
  NSButtonCell* cell = [[containingView layoutStrategy] deleteButtonCell];
  NSSize cellSize = [cell cellSize];
  float offsetX = floor((NSWidth([self bounds]) - cellSize.width) / 2.0);
  return NSMakeRect(NSMinX([self bounds]) + offsetX,NSMinY([self bounds]) + 2,cellSize.width,cellSize.height);
}

@end