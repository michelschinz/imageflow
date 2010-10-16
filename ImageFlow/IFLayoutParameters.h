//
//  IFLayoutParameters.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFLayoutParameters : NSObject {
  float thumbnailWidth;
  IFExpression* backgroundExpression;
}

+ (IFLayoutParameters*)layoutParameters;

// MARK: Global properties
+ (NSDictionary*)nodeLayerStyle;

+ (CGColorRef)backgroundColor;
+ (float)nodeInternalMargin;
+ (float)gutterWidth;

+ (CGColorRef)nodeBackgroundColor;
+ (CGColorRef)nodeLabelColor;

+ (NSFont*)labelFont;
+ (float)labelFontHeight;

+ (CGColorRef)thumbnailBorderColor;
+ (CGColorRef)displayedThumbnailBorderColor;

+ (CGColorRef)connectorColor;
+ (CGColorRef)connectorLabelColor;
+ (float)connectorArrowSize;

+ (CGColorRef)displayedImageUnlockedBackgroundColor;
+ (CGColorRef)displayedImageLockedBackgroundColor;
+ (CGColorRef)cursorColor;
+ (float)cursorWidth;
+ (float)selectionWidth;

+ (CGColorRef)templateLabelColor;

+ (CGColorRef)highlightBackgroundColor;
+ (CGColorRef)highlightBorderColor;

+ (NSFont*)dragBadgeFont;
+ (float)dragBadgeFontHeight;

// MARK: Local properties
@property(nonatomic) float thumbnailWidth;
@property(retain) IFExpression* backgroundExpression;

@end
