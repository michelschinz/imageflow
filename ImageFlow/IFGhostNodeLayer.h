//
//  IFGhostNodeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFCompositeLayer.h"
#import "IFLayoutParameters.h"
#import "IFTreeNode.h"
#import "IFTree.h"

@interface IFGhostNodeLayer : CALayer<IFBaseLayer> {
  IFLayoutParameters* layoutParameters;
  IFTreeNode* node;
}

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

// IFBaseLayer method
@property(readonly) IFTreeNode* node;

@end
