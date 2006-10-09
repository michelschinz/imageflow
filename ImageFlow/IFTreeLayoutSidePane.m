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
  [self setBounds:[[containingView sidePanePath] bounds]];
  return self;
}

- (void)drawForLocalRect:(NSRect)rect;
{  
  [[containingView sidePaneColor] set];
  [[containingView sidePanePath] fill];
  
  NSButtonCell* deleteButtonCell = [containingView deleteButtonCell];
  [deleteButtonCell setRepresentedObject:[base node]];
  [deleteButtonCell drawWithFrame:[self deleteButtonFrame] inView:containingView];
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  NSPoint offset = [self translation];
  NSPoint localPoint = NSMakePoint(thePoint.x - offset.x, thePoint.y - offset.y);
  return NSPointInRect(localPoint, [self bounds]) && [[containingView sidePanePath] containsPoint:localPoint] ? self : nil;
}

- (void)activateWithMouseDown:(NSEvent*)event;
{
  NSButtonCell* deleteButtonCell = [containingView deleteButtonCell];
  [deleteButtonCell highlight:YES withFrame:[self deleteButtonFrame] inView:containingView];
  [self setNeedsDisplay];
  [deleteButtonCell trackMouse:event inRect:[self frame] ofView:containingView untilMouseUp:NO];
  [deleteButtonCell highlight:NO withFrame:[self deleteButtonFrame] inView:containingView];
  [self setNeedsDisplay];
}

@end

@implementation IFTreeLayoutSidePane (Private)

- (NSRect)deleteButtonFrame;
{
  NSButtonCell* cell = [containingView deleteButtonCell];
  NSSize cellSize = [cell cellSize];
  float offsetX = floor((NSWidth([self bounds]) - cellSize.width) / 2.0);
  return NSMakeRect(NSMinX([self bounds]) + offsetX,NSMinY([self bounds]) + 2,cellSize.width,cellSize.height);
}

@end