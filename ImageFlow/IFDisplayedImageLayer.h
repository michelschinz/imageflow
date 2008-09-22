//
//  IFDisplayedImageLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFDisplayedImageLayer : CALayer {
  CALayer* lockLayer; // not retained
}

+ (id)displayedImageLayer;

@end
