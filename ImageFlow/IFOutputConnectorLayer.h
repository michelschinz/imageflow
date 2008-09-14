//
//  IFOutputConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFBaseLayer.h"

@interface IFOutputConnectorLayer : IFBaseLayer {
  NSString* label;
  float leftReach, rightReach;
}

+ (id)outputConnectorLayerWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@property(retain) NSString* label;
@property float leftReach, rightReach;

@end
