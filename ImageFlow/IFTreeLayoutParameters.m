//
//  IFTreeLayoutParameters.m
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFTreeLayoutParameters.h"

@implementation IFTreeLayoutParameters

- (id)init;
{
  if (![super init])
    return nil;

  columnWidth = 50.0;
  backgroundColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] retain];

  labelFont = [[NSFont fontWithName:@"Verdana" size:9.0] retain];
  NSLayoutManager* layoutManager = [[NSLayoutManager alloc] init];
  labelFontHeight = [layoutManager defaultLineHeightForFont:labelFont];
  [layoutManager release];
  
  sidePaneColor = [[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] retain];
  sidePaneSize = NSMakeSize(15,41);
  
  connectorColor = [[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] retain];
  connectorLabelColor = [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] retain];

  cursorColor = [[NSColor redColor] retain];
  markBackgroundColor = [[NSColor blueColor] retain];

  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(backgroundColor);
  OBJC_RELEASE(markBackgroundColor);
  OBJC_RELEASE(cursorColor);
  OBJC_RELEASE(connectorLabelColor);
  OBJC_RELEASE(connectorColor);
  OBJC_RELEASE(labelFont);
  [super dealloc];
}

- (float)columnWidth;
{
  return columnWidth;
}

- (void)setColumnWidth:(float)newColumnWidth;
{
  float roundedNewColumnWidth = round(newColumnWidth);
  if (roundedNewColumnWidth == columnWidth)
    return;
  columnWidth = roundedNewColumnWidth;
}

@synthesize backgroundColor;

- (float)nodeInternalMargin;
{
  return 4.0;
}

- (float)gutterWidth;
{
  return sidePaneSize.width + 4.0;
}

@synthesize labelFont;
@synthesize labelFontHeight;
@synthesize sidePaneColor;
@synthesize sidePaneSize;

- (float)sidePaneCornerRadius;
{
  return 4.0;
}

@synthesize connectorColor;
@synthesize connectorLabelColor;

- (float)connectorArrowSize;
{
  return 4.0;
}

@synthesize cursorColor;

- (float)cursorWidth;
{
  return 3.0;
}

- (float)selectionWidth;
{
  return 1.0;
}

@synthesize markBackgroundColor;

- (NSColor*)highlightingColor;
{
  return [[NSColor blueColor] colorWithAlphaComponent:0.8];
}

@end
