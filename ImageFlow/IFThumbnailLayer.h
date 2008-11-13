//
//  IFThumbnailLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFConstantExpression.h"
#import "IFVariable.h"

@interface IFThumbnailLayer : CALayer {
  IFTreeNode* node;
  IFVariable* canvasBoundsVar;

  float forcedFrameWidth;
  
  IFConstantExpression* evaluatedExpression;
  float aspectRatio;
  
  CALayer* aliasArrowLayer; // not retained
  CALayer* maskIndicatorLayer; // not retained
}

+ (id)layerForNode:(IFTreeNode*)theNode canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initForNode:(IFTreeNode*)theNode canvasBounds:(IFVariable*)theCanvasBoundsVar;

@property float forcedFrameWidth;

@end
