//
//  IFCenteringClipView.m
//  ImageFlow
//
//  Created by Michel Schinz on 13.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

// taken from http://bergdesign.com/missing_cocoa_docs/nsclipview.html

#import "IFCenteringClipView.h"

@interface IFCenteringClipView (Private)
-(void)centerDocument;
@end

@implementation IFCenteringClipView

- (id)initWithFrame:(NSRect)frameRect;
{
  if (![super initWithFrame:frameRect])
    return nil;
  centerHorizontally = centerVertically = YES;
  return self;
}

- (BOOL)centerHorizontally;
{
  return centerHorizontally;
}

- (void)setCenterHorizontally:(BOOL)newValue;
{
  if (newValue == centerHorizontally)
    return;
  centerHorizontally = newValue;
  [self centerDocument];
}

- (BOOL)centerVertically;
{
  return centerVertically;
}

- (void)setCenterVertically:(BOOL)newValue;
{
  if (newValue == centerVertically)
    return;
  centerVertically = newValue;
  [self centerDocument];
}

// ----------------------------------------
// We need to override this so that the superclass doesn't override our new origin point.

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin;
{
  NSRect docRect = [[self documentView] frame];
  NSRect clipRect = [self bounds];
  NSPoint newScrollPoint = proposedNewOrigin;
  float maxX = docRect.size.width - clipRect.size.width;
  float maxY = docRect.size.height - clipRect.size.height;
  
  // If the clip view is wider than the doc, we can't scroll horizontally
  if (docRect.size.width < clipRect.size.width )
    newScrollPoint.x = centerHorizontally ? roundf( maxX / 2.0 ) : 0.0;
  else
    newScrollPoint.x = roundf( MAX(0,MIN(newScrollPoint.x,maxX)) );
  
  // If the clip view is taller than the doc, we can't scroll vertically
  if( docRect.size.height < clipRect.size.height )
    newScrollPoint.y = centerVertically ? roundf( maxY / 2.0 ) : 0.0;
  else
    newScrollPoint.y = roundf( MAX(0,MIN(newScrollPoint.y,maxY)) );
  
  return newScrollPoint;
}

// ----------------------------------------
// These two methods get called whenever the subview changes

-(void)viewBoundsChanged:(NSNotification *)notification
{
  [super viewBoundsChanged:notification];
  [self centerDocument];
}

-(void)viewFrameChanged:(NSNotification *)notification
{
  [super viewFrameChanged:notification];
  [self centerDocument];
}

// ----------------------------------------
// These superclass methods change the bounds rect directly without sending any notifications,
// so we're not sure what other work they silently do for us. As a result, we let them do their
// work and then swoop in behind to change the bounds origin ourselves. This appears to work
// just fine without us having to reinvent the methods from scratch.

- (void)setFrame:(NSRect)frameRect
{
  [super setFrame:frameRect];
  [self centerDocument];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
  [super setFrameOrigin:newOrigin];
  [self centerDocument];
}

- (void)setFrameSize:(NSSize)newSize
{
  [super setFrameSize:newSize];
  [self centerDocument];
}

- (void)setFrameRotation:(float)angle
{
  [super setFrameRotation:angle];
  [self centerDocument];
}

@end

@implementation IFCenteringClipView (Private)

-(void)centerDocument
{
  NSRect docRect = [[self documentView] frame];
  NSRect clipRect = [self bounds];
  
  if (centerHorizontally && docRect.size.width < clipRect.size.width)
    clipRect.origin.x = roundf( ( docRect.size.width - clipRect.size.width ) / 2.0 );
  
  if (centerVertically && docRect.size.height < clipRect.size.height)
    clipRect.origin.y = roundf( ( docRect.size.height - clipRect.size.height ) / 2.0 );
  
  BOOL cos = [self copiesOnScroll];
  if (cos)
    [self setCopiesOnScroll:NO];
  [self scrollToPoint:clipRect.origin];
  if (cos)
    [self setCopiesOnScroll:cos];
}

@end