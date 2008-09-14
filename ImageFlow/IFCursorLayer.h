//
//  IFCursorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFCursorLayer : IFLayer {
  NSBezierPath* outlinePath;
  BOOL isCursor;
}

+ (id)cursorLayerWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@property(retain) NSBezierPath* outlinePath;
@property BOOL isCursor;

@end
