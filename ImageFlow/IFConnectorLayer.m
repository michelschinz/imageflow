//
//  IFConnectorLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 22.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFConnectorLayer.h"
#import "IFLayoutParameters.h"
#import "IFInputConnectorLayer.h"
#import "IFOutputConnectorLayer.h"

@implementation IFConnectorLayer

+ (id)connectorLayerForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  if (theKind == IFConnectorKindInput)
    return [[[IFInputConnectorLayer alloc] initForNode:theNode kind:theKind] autorelease];
  else
    return [[[IFOutputConnectorLayer alloc] initForNode:theNode kind:theKind] autorelease];
}

- (id)initForNode:(IFTreeNode*)theNode kind:(IFConnectorKind)theKind;
{
  if (![super init])
    return nil;
  
  node = [theNode retain];
  self.needsDisplayOnBoundsChange = YES;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(node);
  [super dealloc];
}

@synthesize node;

- (IFConnectorKind)kind;
{
  [self doesNotRecognizeSelector:_cmd];
  return IFConnectorKindInput;
}

@end