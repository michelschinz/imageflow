//
//  IFBorderlessWindow.m
//  ImageFlow
//
//  Created by Michel Schinz on 31.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFBorderlessWindow.h"


@implementation IFBorderlessWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation;
{
  return [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
}

- (BOOL)canBecomeKeyWindow;
{
  return YES;
}

@end
