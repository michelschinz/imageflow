//
//  IFImageOrMaskLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionContentsLayer.h"
#import "IFVariable.h"
#import "IFStaticImageLayer.h"
#import "IFLayoutParameters.h"
#import "IFArrayPath.h"

@interface IFImageOrMaskLayer : IFExpressionContentsLayer {
  // Sublayers (not retained)
  IFStaticImageLayer* maskIndicatorLayer;
  BOOL borderHighlighted;
}

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

@property(nonatomic) BOOL borderHighlighted;

@end
