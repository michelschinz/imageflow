//
//  IFStackLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFNodeLayer.h"
#import "IFConstantExpression.h"
#import "IFVariable.h"

@interface IFStackLayer : CALayer<IFExpressionContentsLayer> {
  IFConstantExpression* expression;
  
  IFLayoutParameters* layoutParameters;
  IFVariable* canvasBoundsVar;
  
  // Sublayers (not retained)
  CATextLayer* countLayer;
  CALayer* foldingButtonLayer;
  CALayer* displayedImageIndicatorLayer;
}

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

- (void)setExpression:(IFConstantExpression*)newExpression;

@end
