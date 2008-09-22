//
//  IFCompositeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"
#import "IFTreeNode.h"

@interface IFCompositeLayer : IFLayer {

}

@property(readonly) BOOL isNode;
@property(readonly) BOOL isInputConnector;
@property(readonly) BOOL isOutputConnector;

@property(readonly, assign) IFLayer* displayedImageLayer; // optional (can be nil)
@property(readonly, assign) IFLayer* baseLayer;
@property(readonly, assign) CALayer* cursorLayer; // optional (can be nil)
@property(readonly, assign) CALayer* highlightLayer;

@property(readonly, assign) IFTreeNode* node;

@end
