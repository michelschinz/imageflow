//
//  IFTreeLayoutMark.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutMark.h"
#import "IFTreeView.h"

@implementation IFTreeLayoutMark

static const float MARGIN = 1.5;

+ (id)layoutMarkWithBase:(IFTreeLayoutSingle*)theBase position:(int)thePosition markIndex:(int)theMarkIndex;
{
  return [[[self alloc] initWithBase:theBase position:thePosition markIndex:theMarkIndex] autorelease];
}

- (id)initWithBase:(IFTreeLayoutSingle*)theBase position:(int)thePosition markIndex:(int)theMarkIndex;
{
  if (![super initWithBase:theBase])
    return nil;

  markIndex = theMarkIndex;
  position = thePosition;
  
  NSMutableParagraphStyle* parStyle = [NSMutableParagraphStyle new];
  [parStyle setAlignment:NSCenterTextAlignment];
  NSDictionary* tagAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
    parStyle, NSParagraphStyleAttributeName,
    [containingView labelFont], NSFontAttributeName,
    [NSColor whiteColor], NSForegroundColorAttributeName,
    nil];
  tag = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",theMarkIndex] attributes:tagAttributes];
  
  NSRect baseBounds = [theBase bounds];
  float sideLen = [containingView labelFontHeight] + 2.0 * MARGIN;
  outlinePath = [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMaxX(baseBounds) - sideLen / 2.0,
                                                                   NSMaxY(baseBounds) - sideLen / 2.0 - (position * (sideLen + 1.0)),
                                                                   sideLen,
                                                                   sideLen)] retain];
  [self setBounds:[outlinePath bounds]];

  return self;
}

- (void) dealloc;
{
  [outlinePath release];
  outlinePath = nil;
  [tag release];
  tag = nil;
  [super dealloc];
}

- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
{
  NSPoint offset = [self translation];
  NSPoint localPoint = NSMakePoint(thePoint.x - offset.x, thePoint.y - offset.y);
  return [outlinePath containsPoint:localPoint] ? self : nil;
}

- (void)drawForLocalRect:(NSRect)rect;
{
  [[containingView markBackgroundColor] set];
  [outlinePath fill];
  [tag drawInRect:NSOffsetRect([self bounds],MARGIN,MARGIN)];
}

- (int)markIndex;
{
  return markIndex;
}

@end
