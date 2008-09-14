//
//  IFLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutParameters.h"
#import "IFTreeNode.h"

@interface IFLayer : CALayer {
  IFTreeLayoutParameters* layoutParameters;
}

- (id)initWithLayoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

- (void)drawInContext:(CGContextRef)context;
- (void)drawInCurrentNSGraphicsContext; // abstract

@end
