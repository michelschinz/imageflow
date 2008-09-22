//
//  IFNodeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFConstantExpression.h"
#import "IFThumbnailLayer.h"

@interface IFNodeLayer : IFLayer {
  IFTreeNode* node;

  // Component layers (not retained)
  CATextLayer* labelLayer;
  IFThumbnailLayer* thumbnailLayer;
  CATextLayer* nameLayer;
}

+ (id)layerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@property(readonly, assign) IFTreeNode* node;

@property(readonly, assign) CATextLayer* labelLayer;
@property(readonly, assign) IFThumbnailLayer* thumbnailLayer;
@property(readonly, assign) CATextLayer* nameLayer;

@property(readonly, retain) NSImage* dragImage;

@end
