//
//  IFGhostNodeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFGhostNodeLayer.h"

@implementation IFGhostNodeLayer

static NSString* IFThumbnailWidthChangedContext = @"IFThumbnailWidthChangedContext";

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithNode:theNode ofTree:theTree layoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super init])
    return nil;
  
  node = [theNode retain];
  layoutParameters = [theLayoutParameters retain];

  self.style = [IFLayoutParameters nodeLayerStyle];
  
  [layoutParameters addObserver:self forKeyPath:@"thumbnailWidth" options:NSKeyValueObservingOptionInitial context:IFThumbnailWidthChangedContext];
  
  return self;
}

- (void)dealloc;
{
  [layoutParameters removeObserver:self forKeyPath:@"thumbnailWidth"];
  
  OBJC_RELEASE(layoutParameters);
  OBJC_RELEASE(node);
  [super dealloc];
}

@synthesize node;

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == IFThumbnailWidthChangedContext)
    self.bounds = CGRectMake(0, 0, layoutParameters.thumbnailWidth, 20.0); // TODO: get height from NSCell
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
