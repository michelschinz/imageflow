//
//  IFImageOrMaskLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImageConstantExpression.h"
#import "IFVariable.h"
#import "IFNodeLayer.h"
#import "IFStaticImageLayer.h"
#import "IFLayoutParameters.h"

@interface IFImageOrMaskLayer : CALayer<IFExpressionContentsLayer> {
  IFConstantExpression* expression;
  
  IFLayoutParameters* layoutParameters;
  IFVariable* canvasBoundsVar;
  
  // Sublayers (not retained)
  IFStaticImageLayer* maskIndicatorLayer;
}

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

- (void)setExpression:(IFConstantExpression*)newExpression;

@end
