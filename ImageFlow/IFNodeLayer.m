//
//  IFNodeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFNodeLayer.h"
#import "IFOperatorExpression.h"
#import "IFErrorConstantExpression.h"
#import "IFLayoutParameters.h"

@interface IFNodeLayer (Private)
- (void)setupComponentLayersWithCanvasBounds:(IFVariable*)canvasBoundsVar;
- (void)teardownComponentLayers;
@end

@implementation IFNodeLayer

static NSString* IFNodeLabelChangedContext = @"IFNodeLabelChangedContext";
static NSString* IFNodeNameChangedContext = @"IFNodeNameChangedContext";

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithNode:theNode ofTree:theTree canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super init])
    return nil;

  node = [theNode retain];
  tree = [theTree retain];
  
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  self.cornerRadius = layoutParameters.nodeInternalMargin;
  self.backgroundColor = layoutParameters.nodeBackgroundColor;
  
  if (!node.isGhost)
    [self setupComponentLayersWithCanvasBounds:theCanvasBoundsVar];

  return self;
}

- (void)dealloc;
{
  if (!node.isGhost)
    [self teardownComponentLayers];

  OBJC_RELEASE(tree);
  OBJC_RELEASE(node);
  [super dealloc];
}

@synthesize node;
@synthesize labelLayer, thumbnailLayer, nameLayer;

- (CGSize)preferredFrameSize;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  float height;
  if (node.isGhost) {
    height = 20.0;  // TODO: use size obtained from NSCell's methods
  } else {
    height = 2.0 * layoutParameters.nodeInternalMargin;
    if (nameLayer.string != nil)
      height += [nameLayer preferredFrameSize].height + layoutParameters.nodeInternalMargin;
    height += [thumbnailLayer preferredFrameSize].height;
    height += [labelLayer preferredFrameSize].height + layoutParameters.nodeInternalMargin;
  }
  
  return CGSizeMake(layoutParameters.columnWidth, height);
}

- (void)layoutSublayers;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float internalMargin = layoutParameters.nodeInternalMargin;
  const float internalWidth = layoutParameters.columnWidth - 2.0 * internalMargin;
  
  const float x = internalMargin;
  float y = internalMargin;
  
  if (nameLayer.string != nil) {
    nameLayer.frame = CGRectMake(x, y, internalWidth, [nameLayer preferredFrameSize].height);
    y += CGRectGetHeight(nameLayer.bounds) + internalMargin;
  }
  
  thumbnailLayer.frame = (CGRect){ CGPointMake(x, y), [thumbnailLayer preferredFrameSize] };
  y += CGRectGetHeight(thumbnailLayer.bounds) + internalMargin;
  
  labelLayer.frame = CGRectMake(x, y, internalWidth, [labelLayer preferredFrameSize].height);
  
  if (!CGSizeEqualToSize(self.frame.size, [self preferredFrameSize]))
    [self.superlayer setNeedsLayout];
}

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
  CGImageRef cgTransparentDragImage = CGBitmapContextCreateImage(ctx);
  
  NSImageRep* imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:cgTransparentDragImage] autorelease];
  CGImageRelease(cgTransparentDragImage);
  CGContextRelease(ctx);
  CGColorSpaceRelease(colorSpace);
  
  NSImage* dragImage = [[[NSImage alloc] init] autorelease];
  [dragImage addRepresentation:imageRep];
  return dragImage;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFNodeLabelChangedContext) {
    labelLayer.string = node.label;
  } else if (context == IFNodeNameChangedContext) {
    nameLayer.string = node.name;
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

@end

@implementation IFNodeLayer (Private)

- (void)setupComponentLayersWithCanvasBounds:(IFVariable*)canvasBoundsVar;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  // Create component layers
  labelLayer = [CATextLayer layer];
  labelLayer.font = layoutParameters.labelFont;
  labelLayer.fontSize = layoutParameters.labelFont.pointSize;
  labelLayer.foregroundColor = layoutParameters.nodeLabelColor;
  labelLayer.alignmentMode = kCAAlignmentCenter;
  labelLayer.truncationMode = kCATruncationMiddle;
  labelLayer.anchorPoint = CGPointZero;
  [self addSublayer:labelLayer];
  
  // Thumbnail
  thumbnailLayer = [IFThumbnailLayer layerForNode:node canvasBounds:canvasBoundsVar];
  [self addSublayer:thumbnailLayer];
  
  nameLayer = [CATextLayer layer];
  nameLayer.font = layoutParameters.labelFont;
  nameLayer.fontSize = layoutParameters.labelFont.pointSize;
  nameLayer.foregroundColor = labelLayer.foregroundColor;
  nameLayer.alignmentMode = kCAAlignmentCenter;
  nameLayer.truncationMode = kCATruncationMiddle;
  nameLayer.anchorPoint = CGPointZero;
  [self addSublayer:nameLayer];
  
  [node addObserver:self forKeyPath:@"label" options:NSKeyValueObservingOptionInitial context:IFNodeLabelChangedContext];
  [node addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionInitial context:IFNodeNameChangedContext];
}

- (void)teardownComponentLayers;
{
  [labelLayer removeFromSuperlayer];
  labelLayer = nil;
  [thumbnailLayer removeFromSuperlayer];
  thumbnailLayer = nil;
  [nameLayer removeFromSuperlayer];
  nameLayer = nil;
}

@end

