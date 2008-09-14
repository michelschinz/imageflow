//
//  IFTreeLayoutParameters.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFTreeLayoutParameters : NSObject {
  CGRect canvasBounds;
  
  NSColor* backgroundColor;
  float columnWidth;
  
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

@property CGRect canvasBounds;
@property float columnWidth;

@property(readonly, retain) NSColor* backgroundColor;
@property(readonly) float nodeInternalMargin;
@property(readonly) float gutterWidth;
@property(readonly, retain) NSFont* labelFont;
@property(readonly) float labelFontHeight;

@property(readonly, retain) NSColor* sidePaneColor;
@property(readonly) NSSize sidePaneSize;
@property(readonly) float sidePaneCornerRadius;

@property(readonly, retain) NSColor* connectorColor;
@property(readonly, retain) NSColor* connectorLabelColor;
@property(readonly) float connectorArrowSize;

@property(readonly, retain) NSColor* cursorColor;
@property(readonly) float cursorWidth;
@property(readonly) float selectionWidth;

@property(readonly, retain) NSColor* markBackgroundColor;
@property(readonly, retain) NSColor* highlightingColor;

@end
