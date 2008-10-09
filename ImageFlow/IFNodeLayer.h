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

@interface IFNodeLayer : CALayer {
  IFTreeNode* node;
  IFTree* tree;

  // Component layers (not retained)
  CATextLayer* labelLayer;
  IFThumbnailLayer* thumbnailLayer;
  CATextLayer* nameLayer;
}

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;

@property(readonly) IFTreeNode* node;

@property(readonly) CATextLayer* labelLayer;
@property(readonly) IFThumbnailLayer* thumbnailLayer;
@property(readonly) CATextLayer* nameLayer;

@property(readonly) NSImage* dragImage;

@end
