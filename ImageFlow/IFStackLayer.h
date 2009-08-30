//
//  IFStackLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpressionContentsLayer.h"
#import "IFVariable.h"

@interface IFStackLayer : IFExpressionContentsLayer {
  // Sublayers (not retained)
  CATextLayer* countLayer;
}

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

@end
