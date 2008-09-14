//
//  IFConnectorCompositeLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFCompositeLayer.h"

typedef enum {
  IFConnectorKindInput,
  IFConnectorKindOutput
} IFConnectorKind;

@interface IFConnectorCompositeLayer : IFCompositeLayer {
  IFConnectorKind kind;
}

+ (id)layerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
- (id)initWithNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;

@end
