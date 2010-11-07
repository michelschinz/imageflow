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
#import "IFCompositeLayer.h"
#import "IFLayoutParameters.h"
#import "IFStaticImageLayer.h"
#import "IFExpressionContentsLayer.h"

@interface IFNodeLayer : CALayer<IFBaseLayer> {
  IFTreeNode* node;
  IFTree* tree;

  IFLayoutParameters* layoutParameters;
  IFVariable* canvasBounds;

  // Sublayers (not retained)
  CATextLayer* labelLayer;
  IFStaticImageLayer* aliasArrowLayer;
  CALayer* foldingSeparatorLayer;
  IFExpressionContentsLayer* expressionLayer;
  CATextLayer* nameLayer;
}

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

// IFBaseLayer methods
@property(readonly) IFTreeNode* node;
@property(readonly) NSImage* dragImage;

@property(readonly) CATextLayer* labelLayer;
@property(readonly, nonatomic) IFExpressionContentsLayer* expressionLayer;
@property(readonly) CATextLayer* nameLayer;
@property(readonly) NSArray* thumbnailLayers;

@end
