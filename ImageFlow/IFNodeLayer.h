//
//  IFNodeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFBaseLayer.h"
#import "IFTreeNode.h"
#import "IFConstantExpression.h"

@interface IFNodeLayer : IFBaseLayer {
  BOOL isSource, isSink, isMask;
  
  // Internal layout state (set by updateInternalLayout)
  BOOL showsErrorSign;
  float thumbnailAspectRatio;
  CGRect labelFrame;
  CGRect thumbnailFrame;
  CGRect nameFrame;
  IFConstantExpression* evaluatedExpression;
}

+ (id)layerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
