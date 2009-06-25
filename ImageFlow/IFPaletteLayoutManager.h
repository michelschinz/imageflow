//
//  IFPaletteLayoutManager.h
//  ImageFlow
//
//  Created by Michel Schinz on 23.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayoutParameters.h"

@class IFPaletteLayoutManager;
@protocol IFPaletteLayoutManagerDelegate
- (void)layoutManager:(IFPaletteLayoutManager*)layoutManager didLayoutSublayersOfLayer:(CALayer*)layer;
@end

@interface IFPaletteLayoutManager : NSObject {
  IFLayoutParameters* layoutParameters;
  id<IFPaletteLayoutManagerDelegate> delegate;
}

+ (id)paletteLayoutManager;

@property(retain) IFLayoutParameters* layoutParameters;
@property(assign) id<IFPaletteLayoutManagerDelegate> delegate;

- (void)layoutSublayersOfLayer:(CALayer*)layer;

@end
