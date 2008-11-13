//
//  IFNodeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFTreeNode.h"
#import "IFConstantExpression.h"
#import "IFThumbnailLayer.h"
#import "IFCompositeLayer.h"

@interface IFNodeLayer : CALayer<IFBaseLayer> {
  IFTreeNode* node;
  IFTree* tree;
  float forcedFrameWidth;

  // Component layers (not retained)
  CATextLayer* labelLayer;
  CALayer* foldingSeparatorLayer;
  IFThumbnailLayer* thumbnailLayer;
  CATextLayer* nameLayer;
}

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;

// IFBaseLayer method
@property(readonly) IFTreeNode* node;
@property float forcedFrameWidth;

@property(readonly) CATextLayer* labelLayer;
@property(readonly) IFThumbnailLayer* thumbnailLayer;
@property(readonly) CATextLayer* nameLayer;

@property(readonly) NSImage* dragImage;

@end
