//
//  IFLayoutParameters.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayoutParameters.h"


@implementation IFLayoutParameters

static IFLayoutParameters* sharedLayoutParameters = nil;

+ (IFLayoutParameters*)sharedLayoutParameters;
{
  if (sharedLayoutParameters == nil)
    sharedLayoutParameters = [[self alloc] init];
  return sharedLayoutParameters;
}

- (id)init;
{
  if (![super init])
    return nil;
 
  columnWidth = 50;
  
  backgroundColor = CGColorCreateGenericGray(0.5, 1.0);
  nodeInternalMargin = 3.0;
  gutterWidth = 30.0;
  
  labelFont = [[NSFont fontWithName:@"Verdana" size:9.0] retain];
  NSLayoutManager* layoutManager = [[[NSLayoutManager alloc] init] autorelease];
  labelFontHeight = [layoutManager defaultLineHeightForFont:labelFont];
  
  connectorColor = CGColorCreateGenericGray(0.2, 1.0);
  connectorLabelColor = CGColorCreateGenericGray(0.6, 1.0);
  connectorArrowSize = 4.0;
  
  cursorColor = CGColorCreateGenericRGB(1, 0, 0, 1);
  cursorWidth = 3.0;
  selectionWidth = 1.0;
  
  highlightColor = CGColorCreateGenericRGB(0, 0, 1, 0.8);
  
  return self;
}

- (CGRect)canvasBounds;
{
  return CGRectMake(0, 0, 800, 600);
}

@synthesize columnWidth;

@synthesize backgroundColor;
@synthesize nodeInternalMargin;
@synthesize gutterWidth;

@synthesize labelFont, labelFontHeight;

@synthesize connectorColor, connectorLabelColor, connectorArrowSize;

@synthesize cursorColor, cursorWidth, selectionWidth;
@synthesize highlightColor;

@end
