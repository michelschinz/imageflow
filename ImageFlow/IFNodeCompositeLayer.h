//
//  IFNodeCompositeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 16.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFCompositeLayer.h"
#import "IFNodeLayer.h"
#import "IFCursorLayer.h"

@interface IFNodeCompositeLayer : IFCompositeLayer {
}

+ (id)layerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
