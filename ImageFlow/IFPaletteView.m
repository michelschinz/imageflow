//
//  IFPaletteView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFPaletteView.h"


@implementation IFPaletteView

- (id)initWithFrame:(NSRect)frame;
{
  return [super initWithFrame:frame];
}

- (void)drawRect:(NSRect)rect;
{
  [[layoutParameters backgroundColor] set];
  NSRectFill(rect);
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self setFrameSize:[[self superview] frame].size];
  [self setNeedsDisplay:YES];
}

@end
