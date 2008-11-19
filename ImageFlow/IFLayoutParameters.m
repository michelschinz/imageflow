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
 
  backgroundColor = CGColorCreateGenericGray(0.5, 1.0);
  nodeInternalMargin = 3.0;
  gutterWidth = 30.0;
  
  nodeBackgroundColor = CGColorCreateGenericGray(1.0, 1.0);
  nodeLabelColor = CGColorCreateGenericGray(0.0, 1.0);
  
  labelFont = [[NSFont fontWithName:@"Verdana" size:9.0] retain];
  NSLayoutManager* layoutManager = [[[NSLayoutManager alloc] init] autorelease];
  labelFontHeight = [layoutManager defaultLineHeightForFont:labelFont];
  
  connectorColor = CGColorCreateGenericGray(0.3, 1.0);
  connectorLabelColor = CGColorCreateGenericGray(0.6, 1.0);
  connectorArrowSize = 5.0;

  displayedImageUnlockedBackgroundColor = CGColorCreateGenericGray(0.75, 1.0);
  displayedImageLockedBackgroundColor = CGColorCreateGenericRGB(0.9, 0.75, 0.75, 1.0);

  cursorColor = CGColorCreateGenericRGB(1, 0, 0, 1);
  cursorWidth = 3.0;
  selectionWidth = 1.0;
  
  templateLabelColor = CGColorCreateGenericGray(1.0, 1.0);
  
  highlightBackgroundColor = CGColorCreateGenericRGB(0, 0, 1, 0.8);
  highlightBorderColor = CGColorCreateGenericRGB(0, 0, 1, 1.0);
  
  dragBadgeFont = [[NSFont fontWithName:@"LucidaGrande-Bold" size:11.0] retain];
  dragBadgeFontHeight = [layoutManager defaultLineHeightForFont:dragBadgeFont];
  
  return self;
}

@synthesize backgroundColor;
@synthesize nodeInternalMargin;
@synthesize gutterWidth;

@synthesize nodeBackgroundColor, nodeLabelColor;

@synthesize labelFont, labelFontHeight;

@synthesize connectorColor, connectorLabelColor, connectorArrowSize;

@synthesize displayedImageUnlockedBackgroundColor, displayedImageLockedBackgroundColor;
@synthesize cursorColor, cursorWidth, selectionWidth;

@synthesize templateLabelColor;

@synthesize highlightBackgroundColor, highlightBorderColor;

@synthesize dragBadgeFont, dragBadgeFontHeight;

@end
