//
//  IFConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorLayer.h"


@implementation IFConnectorLayer

- (id)initForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;
  node = [theNode retain];
  self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  self.needsDisplayOnBoundsChange = YES;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(node);
  [super dealloc];
}

@synthesize node;
@synthesize outlinePath;

@end
