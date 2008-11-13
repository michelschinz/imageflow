//
//  IFConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFCompositeLayer.h"
#import "IFTreeNode.h"

typedef enum {
  IFConnectorKindInput,
  IFConnectorKindOutput
} IFConnectorKind;

@interface IFConnectorLayer : CALayer<IFBaseLayer> {
  IFTreeNode* node;
  IFConnectorKind kind;
  float forcedFrameWidth;
  CGPathRef outlinePath;
}

+ (id)connectorLayerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
- (id)initForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;

// IFBaseLayer method
@property(readonly) IFTreeNode* node;
@property float forcedFrameWidth;

@property(readonly) IFConnectorKind kind;

@property CGPathRef outlinePath;

// MARK: -
// MARK: PROTECTED
- (CGPathRef)createOutlinePath; // abstract

@end
