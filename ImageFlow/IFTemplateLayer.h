//
//  IFTemplateLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeTemplate.h"
#import "IFTree.h"
#import "IFNodeCompositeLayer.h"
#import "IFTreeNode.h"
#import "IFLayoutParameters.h"

@interface IFTemplateLayer : CALayer {
  IFTreeTemplate* treeTemplate;
  
  IFLayoutParameters* layoutParameters;
  
  // Normal mode
  IFTree* normalModeTree;
  IFNodeCompositeLayer* normalNodeCompositeLayer;

  // Preview mode (tree and layer are nil when not in preview mode)
  IFTree* previewModeTree;
  IFNodeCompositeLayer* previewNodeCompositeLayer;
  unsigned visibilityFlags;
  
  // Sublayers (not retained)
  CALayer* arityIndicatorLayer;
  CATextLayer* nameLayer;
}

+ (IFTemplateLayer*)layerForTemplate:(IFTreeTemplate*)theTreeTemplate layoutParameters:(IFLayoutParameters*)theLayoutParameters;
- (IFTemplateLayer*)initForTemplate:(IFTreeTemplate*)theTreeTemplate layoutParameters:(IFLayoutParameters*)theLayoutParameters;

@property(readonly) IFTreeTemplate* treeTemplate;
@property(readonly) IFTree* tree;
@property(readonly) IFTreeNode* treeNode;

- (void)switchToPreviewModeForNode:(IFTreeNode*)node ofTree:(IFTree*)tree canvasBounds:(IFVariable*)canvasBoundsVar;
- (void)switchToNormalMode;
@property BOOL filterOut;

@property(readonly) IFNodeCompositeLayer* nodeCompositeLayer;
@property(readonly) CATextLayer* nameLayer;

@property(readonly) NSImage* dragImage;

@end
