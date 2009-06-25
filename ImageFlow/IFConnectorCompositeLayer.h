//
//  IFConnectorCompositeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFCompositeLayer.h"
#import "IFConnectorLayer.h"
#import "IFPathLayer.h"

@interface IFConnectorCompositeLayer : IFCompositeLayer {
  // Sublayers (not retained)
  IFConnectorLayer* baseLayer;
  IFPathLayer* highlightLayer;
}

+ (id)layerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
- (id)initWithNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;

@property(readonly) CALayer<IFBaseLayer>* baseLayer;
@property(readonly) CALayer* highlightLayer;

@end
