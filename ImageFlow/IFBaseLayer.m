//
//  IFBaseLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFBaseLayer.h"


@implementation IFBaseLayer

+ (id)baseLayerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initForNode:theNode layoutParameters:theLayoutParameters] autorelease];
}

- (id)initForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initWithLayoutParameters:theLayoutParameters])
    return nil;
  node = [theNode retain];

  self.autoresizingMask = kCALayerHeightSizable|kCALayerWidthSizable; // make sure our size is the same as the size of the composite
  self.needsDisplayOnBoundsChange = YES;
  
  return self;
}

- (void) dealloc;
{
  OBJC_RELEASE(node);
  [super dealloc];
}

@synthesize node;
@synthesize outlinePath;

- (NSImage*)dragImage;
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
