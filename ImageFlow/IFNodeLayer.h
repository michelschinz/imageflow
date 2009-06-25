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

@protocol IFExpressionContentsLayer
- (void)setExpression:(IFConstantExpression*)newExpression;
@end

@interface IFNodeLayer : CALayer<IFBaseLayer> {
  IFTreeNode* node;
  IFTree* tree;

  IFLayoutParameters* layoutParameters;
  IFVariable* canvasBounds;
  
  // Component layers (not retained)
  CATextLayer* labelLayer;
  CALayer* foldingSeparatorLayer;
  CALayer<IFExpressionContentsLayer>* expressionLayer;
  CATextLayer* nameLayer;
}

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

// IFBaseLayer method
@property(readonly) IFTreeNode* node;

@property(readonly) CATextLayer* labelLayer;
@property(readonly) CALayer<IFExpressionContentsLayer>* expressionLayer;
@property(readonly) CATextLayer* nameLayer;

@property(readonly) NSImage* dragImage;

@end
