//
//  IFHistogramView.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFHistogramView : NSView {
  NSArray* histogramsRGB;
  int displayedChannelIndex;
  BOOL useColor;
}

- (void)setHistogramsRGB:(NSArray*)newHistogramsRGB;

- (NSArray*)channelNames;

- (int)displayedChannelIndex;
- (void)setDisplayedChannelIndex:(int)newDisplayedChannelIndex;

- (BOOL)useColor;
- (void)setUseColor:(BOOL)newUseColor;

@end
