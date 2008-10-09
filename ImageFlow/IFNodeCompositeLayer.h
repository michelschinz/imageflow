//
//  IFNodeCompositeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 16.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFCompositeLayer.h"
#import "IFTree.h"
#import "IFVariable.h"

@interface IFNodeCompositeLayer : IFCompositeLayer {
}

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;

@end
