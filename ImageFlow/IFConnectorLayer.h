//
//  IFConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

typedef enum {
  IFConnectorKindInput,
  IFConnectorKindOutput
} IFConnectorKind;

@interface IFConnectorLayer : CALayer {
  IFTreeNode* node;
  IFConnectorKind kind;
  CGPathRef outlinePath;
}

+ (id)connectorLayerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
- (id)initForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;

@property(readonly) IFTreeNode* node;
@property(readonly) IFConnectorKind kind;

@property CGPathRef outlinePath;

// MARK: (protected)
- (CGPathRef)createOutlinePath; // abstract

@end
