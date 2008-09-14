//
//  IFBaseLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFBaseLayer : IFLayer {
  IFTreeNode* node;
  NSBezierPath* outlinePath;
}

+ (id)baseLayerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@property(readonly, retain) IFTreeNode* node;
@property(retain) NSBezierPath* outlinePath;
@property(readonly, retain) NSImage* dragImage;

@end
