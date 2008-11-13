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

@interface IFConnectorLayer (Private)
- (void)updateOutlinePath;
@end

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
  kind = theKind;

  self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  self.needsDisplayOnBoundsChange = YES;
  
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(node);
  CGPathRelease(outlinePath);
  [super dealloc];
}

@synthesize node;
@synthesize forcedFrameWidth;

@synthesize kind;

- (CGPathRef)outlinePath;
{
  return outlinePath;
}

- (void)setOutlinePath:(CGPathRef)newOutlinePath;
{
  if (newOutlinePath == outlinePath)
    return;
  CGPathRelease(outlinePath);
  outlinePath = CGPathRetain(newOutlinePath);
}

- (CGSize)preferredFrameSize;
{
  [self updateOutlinePath];
  return CGPathGetBoundingBox(outlinePath).size;
}

- (void)drawInContext:(CGContextRef)context;
{
  [self updateOutlinePath];

  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  CGContextAddPath(context, outlinePath);
  CGContextSetFillColorWithColor(context, layoutParameters.connectorColor);
  CGContextFillPath(context);
}

- (CGPathRef)createOutlinePath;
{
  [self doesNotRecognizeSelector:_cmd];
  return NULL;
}

@end

@implementation IFConnectorLayer (Private)

- (void)updateOutlinePath;
{
  CGPathRef newOutlinePath = [self createOutlinePath];
  self.outlinePath = newOutlinePath;
  CGPathRelease(newOutlinePath);
}

@end
