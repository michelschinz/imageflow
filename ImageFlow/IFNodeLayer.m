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
- (void)setupComponentLayers;
- (void)teardownComponentLayers;

- (void)updateLabel;
- (void)updateName;
@end

@implementation IFNodeLayer

static NSString* IFNodeLabelChangedContext = @"IFNodeLabelChangedContext";
static NSString* IFNodeNameChangedContext = @"IFNodeNameChangedContext";

+ (id)layerForNode:(IFTreeNode*)theNode;
{
  return [[[self alloc] initWithNode:theNode] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode;
{
  if (![super init])
    return nil;

  node = [theNode retain];
  
  self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  self.cornerRadius = [IFLayoutParameters sharedLayoutParameters].nodeInternalMargin;
  CGColorRef whiteColor = CGColorCreateGenericRGB(1, 1, 1, 1);
  self.backgroundColor = whiteColor;
  CGColorRelease(whiteColor);
  
  [self setupComponentLayers];

  return self;
}

- (void)dealloc;
{
  [self teardownComponentLayers];

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

  // TODO: find an easy way to set alpha to 0.6 (setting it with CGContextSetAlpha does not work).
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
  [self renderInContext:ctx];  
  CGImageRef cgDragImage = CGBitmapContextCreateImage(ctx);
  NSImageRep* imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:cgDragImage] autorelease];
  CGImageRelease(cgDragImage);
  CGContextRelease(ctx);
  CGColorSpaceRelease(colorSpace);
  
  NSImage* dragImage = [[[NSImage alloc] init] autorelease];
  [dragImage addRepresentation:imageRep];
  return dragImage;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFNodeLabelChangedContext) {
    [self updateLabel];
  } else if (context == IFNodeNameChangedContext) {
    [self updateName];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

@end

@implementation IFNodeLayer (Private)

- (void)setupComponentLayers;
{
  if (node.isGhost)
    return;
  
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  // Create component layers
  labelLayer = [CATextLayer layer];
  labelLayer.font = layoutParameters.labelFont;
  labelLayer.fontSize = layoutParameters.labelFont.pointSize;
  CGColorRef blackColor = CGColorCreateGenericRGB(0, 0, 0, 1);
  labelLayer.foregroundColor = blackColor;
  CGColorRelease(blackColor);
  labelLayer.alignmentMode = kCAAlignmentCenter;
  labelLayer.truncationMode = kCATruncationMiddle;
  labelLayer.anchorPoint = CGPointZero;
  [self updateLabel];
  [self addSublayer:labelLayer];
  
  thumbnailLayer = [IFThumbnailLayer layerForNode:node];
  [self addSublayer:thumbnailLayer];
  
  nameLayer = [CATextLayer layer];
  nameLayer.font = layoutParameters.labelFont;
  nameLayer.fontSize = layoutParameters.labelFont.pointSize;
  nameLayer.foregroundColor = labelLayer.foregroundColor;
  nameLayer.alignmentMode = kCAAlignmentCenter;
  nameLayer.truncationMode = kCATruncationMiddle;
  nameLayer.anchorPoint = CGPointZero;
  [self updateName];
  [self addSublayer:nameLayer];
  
  [node addObserver:self forKeyPath:@"label" options:0 context:IFNodeLabelChangedContext];
  [node addObserver:self forKeyPath:@"name" options:0 context:IFNodeNameChangedContext];
}

- (void)teardownComponentLayers;
{
  if (node.isGhost)
    return;
  
  [node removeObserver:self forKeyPath:@"name"];
  [node removeObserver:self forKeyPath:@"label"];  
}

- (void)updateLabel;
{
  labelLayer.string = node.label;
}

- (void)updateName;
{
  nameLayer.string = node.name;
}

@end

