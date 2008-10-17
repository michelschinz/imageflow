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
  IFNodeCompositeLayer* normalNodeCompositeLayer;

  // Preview mode
  IFNodeCompositeLayer* previewNodeCompositeLayer; // (nil when not in preview mode)
  
  // Sublayers (not retained)
  CALayer* arityIndicatorLayer;
  CATextLayer* nameLayer;
}

+ (IFTemplateLayer*)layerForTemplate:(IFTreeTemplate*)theTreeTemplate;
- (IFTemplateLayer*)initForTemplate:(IFTreeTemplate*)theTreeTemplate;

@property(readonly) IFTreeTemplate* treeTemplate;

- (void)switchToPreviewModeForNode:(IFTreeNode*)node ofTree:(IFTree*)tree canvasBounds:(IFVariable*)canvasBoundsVar;
- (void)switchToNormalMode;

@property(readonly) IFNodeCompositeLayer* nodeCompositeLayer;

@property(readonly) NSImage* dragImage;

@end
