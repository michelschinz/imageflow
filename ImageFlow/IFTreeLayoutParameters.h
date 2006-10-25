//
//  IFTreeLayoutParameters.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFTreeLayoutParameters : NSObject {
  float columnWidth;
  NSColor* backgroundColor;

  NSFont* labelFont;
  float labelFontHeight;

  NSColor* sidePaneColor;
  NSSize sidePaneSize;

  NSColor* connectorColor;
  NSColor* connectorLabelColor;
  
  NSColor* cursorColor;
  NSColor* markBackgroundColor;
  NSColor* highlightingColor;
}

- (float)columnWidth;
- (void)setColumnWidth:(float)theColumnWidth;

- (NSColor*)backgroundColor;

- (float)nodeInternalMargin;
- (float)gutterWidth;
- (NSFont*)labelFont;
- (float)labelFontHeight;

- (NSColor*)sidePaneColor;
- (NSSize)sidePaneSize;
- (float)sidePaneCornerRadius;

- (NSColor*)connectorColor;
- (NSColor*)connectorLabelColor;
- (float)connectorArrowSize;

- (NSColor*)cursorColor;
- (float)cursorWidth;
- (float)selectionWidth;

- (NSColor*)markBackgroundColor;
- (NSColor*)highlightingColor;

@end
