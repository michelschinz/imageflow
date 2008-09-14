//
//  IFHighlightLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFHighlightLayer : IFLayer {
  NSBezierPath* outlinePath;
}

+ (id)highlightLayerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@property(retain) NSBezierPath* outlinePath;

@end
