//
//  IFTemplateLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeTemplate.h"
#import "IFNodeCompositeLayer.h"
#import "IFTreeNode.h"

@interface IFTemplateLayer : CALayer {
  IFTreeTemplate* treeTemplate;

  // Normal mode
  IFTree* normalModeTree;
  IFNodeCompositeLayer* normalNodeCompositeLayer;

  // Preview mode
  //IFNodeLayer* previewNodeLayer;
  
  // Sublayers
  CALayer* arityIndicatorLayer; // not retained
  IFNodeCompositeLayer* nodeCompositeLayer; // not retained, either normalNodeCompositeLayer or previewNodeLayer
  CATextLayer* nameLayer; // not retained
}

+ (IFTemplateLayer*)layerForTemplate:(IFTreeTemplate*)theTreeTemplate;
- (IFTemplateLayer*)initForTemplate:(IFTreeTemplate*)theTreeTemplate;

@property(readonly) IFTreeTemplate* treeTemplate;

@property(readonly) IFNodeCompositeLayer* nodeCompositeLayer;

//@property(retain) IFTreeNode* previewNode;

@end
