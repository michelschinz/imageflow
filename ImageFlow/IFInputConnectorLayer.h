//
//  IFInputConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConnectorLayer.h"

@interface IFInputConnectorLayer : IFConnectorLayer {
  float width;
}

@property(nonatomic) float width;

@end
