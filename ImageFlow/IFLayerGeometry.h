//
//  IFLayerGeometry.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

CALayer* closestLayerInDirection(CALayer* refLayer, NSArray* candidates, IFDirection direction);
