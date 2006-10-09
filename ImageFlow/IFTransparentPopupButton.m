//
//  IFTransparentPopupButton.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTransparentPopupButton.h"


@implementation IFTransparentPopupButton

- (BOOL)isOpaque;
{
  return NO;
}

- (void)drawRect:(NSRect)rect;
{
  [[NSColor colorWithDeviceWhite:0.0 alpha:0.5] set];
  [NSBezierPath fillRect:[self bounds]];
  [[self title] drawInRect:[self bounds] withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    [NSColor whiteColor], NSForegroundColorAttributeName,
    nil]];
}

@end
