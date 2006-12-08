//
//  IFPaletteView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFPaletteView.h"
#import "IFTreeLayoutComposite.h"

@implementation IFPaletteView

- (id)initWithFrame:(NSRect)frame;
{
  return [super initWithFrame:frame layersCount:1];
}

- (IFTreeLayoutParameters*)layoutParameters;
{
  return layoutParameters;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self setFrameSize:[[self superview] frame].size];
  [self setNeedsDisplay:YES];
}

- (IFTreeLayoutElement*)layoutForLayer:(int)layer;
{
  return [IFTreeLayoutComposite layoutComposite];
}

@end
