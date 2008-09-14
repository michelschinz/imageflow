//
//  IFGhostNodeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFBaseLayer.h"

@interface IFGhostNodeLayer : IFBaseLayer {
}

+ (id)ghostLayerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
