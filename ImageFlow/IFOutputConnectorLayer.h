//
//  IFOutputConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 05.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConnectorLayer.h"

@interface IFOutputConnectorLayer : IFConnectorLayer {
  CATextLayer* labelLayer; // not retained
  float leftReach, rightReach;
}

@property(retain) NSString* label;
@property float leftReach, rightReach;

@end
