//
//  IFDisplayedImageLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFDisplayedImageLayer : IFLayer {
  CALayer* lockLayer; // not retained
}

+ (id)displayedImageLayerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
