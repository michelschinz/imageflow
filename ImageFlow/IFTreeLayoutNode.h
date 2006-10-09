//
//  IFTreeLayoutNode.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutSingle.h"

@interface IFTreeLayoutNode : IFTreeLayoutSingle {
  // Internal layout state
  NSRect foldingFrame;
  NSRect labelFrame;
  float thumbnailAspectRatio;
  NSRect thumbnailFrame;
  NSRect nameFrame;
  CIFilter* backgroundGenerator;
  CIFilter* backgroundCompositor;

  IFExpressionEvaluator* evaluator;
  IFImageConstantExpression* evaluatedExpression;
}

+ (id)layoutNodeWithNode:(IFTreeNode*)theNode containingView:(IFTreeView*)theContainingView;
- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFTreeView*)theContainingView;

@end
