//
//  IFCompositeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFCompositeLayer : CALayer {

}

@property(readonly) BOOL isNode;
@property(readonly) BOOL isInputConnector;
@property(readonly) BOOL isOutputConnector;

@property(readonly, assign) CALayer* displayedImageLayer; // optional (can be nil)
@property(readonly, assign) CALayer* baseLayer;
@property(readonly, assign) CALayer* cursorLayer; // optional (can be nil)
@property(readonly, assign) CALayer* highlightLayer;

@property(readonly, assign) IFTreeNode* node;

@end
