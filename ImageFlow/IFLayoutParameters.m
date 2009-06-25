//
//  IFLayoutParameters.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayoutParameters.h"

@implementation IFLayoutParameters

static NSDictionary* nodeLayerStyle;

static CGColorRef backgroundColor;
static float nodeInternalMargin;
static float gutterWidth;

static CGColorRef nodeBackgroundColor;
static CGColorRef nodeLabelColor;

static NSFont* labelFont;
static float labelFontHeight;

static CGColorRef connectorColor;
static CGColorRef connectorLabelColor;
static float connectorArrowSize;

static CGColorRef displayedImageUnlockedBackgroundColor;
static CGColorRef displayedImageLockedBackgroundColor;
static CGColorRef cursorColor;
static float cursorWidth;
static float selectionWidth;

static CGColorRef templateLabelColor;

static CGColorRef highlightBackgroundColor;
static CGColorRef highlightBorderColor;

static NSFont* dragBadgeFont;
static float dragBadgeFontHeight;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key;
{
  return ![key isEqualToString:@"thumbnailWidth"];
}

+ (void)initialize;
{
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

  nodeLayerStyle = [[NSDictionary dictionaryWithObjectsAndKeys:
                     (id)nodeBackgroundColor, @"backgroundColor",
                     [NSNumber numberWithFloat:nodeInternalMargin], @"cornerRadius",
                     [NSValue valueWithPoint:NSMakePoint(0, 0)], @"anchorPoint",
                     nil] retain];  
}

+ (IFLayoutParameters*)layoutParameters;
{
  return [[[self alloc] init] autorelease];
}

- (id)init;
{
  if (![super init])
    return nil;
  thumbnailWidth = 50.0;
  return self;
}

// MARK: Global properties
+ (NSDictionary*)nodeLayerStyle;
{
  return nodeLayerStyle;
}

+ (CGColorRef)backgroundColor;
{
  return backgroundColor;
}

+ (float)nodeInternalMargin;
{
  return nodeInternalMargin;
}

+ (float)gutterWidth;
{
  return gutterWidth;
}

+ (CGColorRef)nodeBackgroundColor;
{
  return nodeBackgroundColor;
}

+ (CGColorRef)nodeLabelColor;
{
  return nodeLabelColor;
}

+ (NSFont*)labelFont;
{
  return labelFont;
}

+ (float)labelFontHeight;
{
  return labelFontHeight;
}

+ (CGColorRef)connectorColor;
{
  return connectorColor;
}

+ (CGColorRef)connectorLabelColor;
{
  return connectorLabelColor;
}

+ (float)connectorArrowSize;
{
  return connectorArrowSize;
}

+ (CGColorRef)displayedImageUnlockedBackgroundColor;
{
  return displayedImageUnlockedBackgroundColor;
}

+ (CGColorRef)displayedImageLockedBackgroundColor;
{
  return displayedImageLockedBackgroundColor;
}

+ (CGColorRef)cursorColor;
{
  return cursorColor;
}

+ (float)cursorWidth;
{
  return cursorWidth;
}

+ (float)selectionWidth;
{
  return selectionWidth;
}

+ (CGColorRef)templateLabelColor;
{
  return templateLabelColor;
}

+ (CGColorRef)highlightBackgroundColor;
{
  return highlightBackgroundColor;
}

+ (CGColorRef)highlightBorderColor;
{
  return highlightBorderColor;
}

+ (NSFont*)dragBadgeFont;
{
  return dragBadgeFont;
}

+ (float)dragBadgeFontHeight;
{
  return dragBadgeFontHeight;
}

// MARK: Local properties

- (void)setThumbnailWidth:(float)newWidth;
{
  float realNewWidth = floor(newWidth);
  if (realNewWidth != newWidth) {
    [self willChangeValueForKey:@"thumbnailWidth"];
    thumbnailWidth = realNewWidth;
    [self didChangeValueForKey:@"thumbnailWidth"];
  }
}

@synthesize thumbnailWidth;

@end
