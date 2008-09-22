//
//  IFConnectorLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFConnectorLayer : IFLayer {
  IFTreeNode* node;
  NSBezierPath* outlinePath;
}

- (id)initForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@property(readonly, retain) IFTreeNode* node;
@property(retain) NSBezierPath* outlinePath;

@end
