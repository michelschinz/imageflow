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

// TODO: avoid code duplication with IFNodeLayer.m
- (NSImage*)dragImage;
{
  size_t width = round(CGRectGetWidth(self.bounds));
  size_t height = round(CGRectGetHeight(self.bounds));
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
  CGRect ctxBounds = CGRectMake(0, 0, width, height);
  
  [self renderInContext:ctx];
  
  CGImageRef cgOpaqueDragImage = CGBitmapContextCreateImage(ctx);
  CGContextClearRect(ctx, ctxBounds);
  CGContextSetAlpha(ctx, 0.6);
  CGContextDrawImage(ctx, ctxBounds, cgOpaqueDragImage);
  CGImageRelease(cgOpaqueDragImage);
  CGImageRef cgTransparentDragImage = CGBitmapContextCreateImage(ctx);
  
  NSImageRep* imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:cgTransparentDragImage] autorelease];
  CGImageRelease(cgTransparentDragImage);
  CGContextRelease(ctx);
  CGColorSpaceRelease(colorSpace);
  
  NSImage* dragImage = [[[NSImage alloc] init] autorelease];
  [dragImage addRepresentation:imageRep];
  return dragImage;
}

- (NSArray*)thumbnailLayers;
{
  return [NSArray array];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == IFThumbnailWidthChangedContext)
    self.bounds = CGRectMake(0, 0, layoutParameters.thumbnailWidth, 20.0); // TODO: get height from NSCell
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
