//
//  IFHighlightLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFConnectorHighlightLayer : CALayer {
  CGPathRef outlinePath;
}

+ (id)highlightLayer;

@property CGPathRef outlinePath;

@end
