//
//  IFInputConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFBaseLayer.h"

@interface IFInputConnectorLayer : IFBaseLayer {

}

+ (id)inputConnectorLayerWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
