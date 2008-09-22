//
//  IFThumbnailLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFThumbnailLayer : IFLayer {
  IFTreeNode* node;
  
  IFConstantExpression* evaluatedExpression;
  float aspectRatio;
  
  CALayer* aliasArrowLayer; // not retained
  CALayer* maskIndicatorLayer; // not retained
}

+ (id)layerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
