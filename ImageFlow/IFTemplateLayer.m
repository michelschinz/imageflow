//
//  IFTemplateLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFTemplateLayer.h"

#import "IFNodeLayer.h"
#import "IFLayoutParameters.h"
#import "IFVariable.h"

@implementation IFTemplateLayer

static IFVariable* normalCanvasBoundsVar = nil;

+ (void)initialize;
{
  if (self != [IFTemplateLayer class])
    return; // avoid repeated initialisation
  
  normalCanvasBoundsVar = [[IFVariable variable] retain];
  normalCanvasBoundsVar.value = [NSValue valueWithRect:NSMakeRect(0, 0, 640, 508)]; // TODO: obtain size from elsewhere
}

static IFTree* computeNormalModeTreeForTemplate(IFTreeTemplate* treeTemplate) {
  IFTree* templateTree = treeTemplate.tree;
  unsigned parentsCount = templateTree.holesCount;
  IFTree* hostTree = [IFTree tree];
  IFTreeNode* ghost = [IFTreeNode ghostNodeWithInputArity:parentsCount];
  [hostTree addNode:ghost];
  for (int j = 0; j < parentsCount; ++j) {
    IFTreeNode* parent = [IFTreeNode universalSourceWithIndex:j];
    [hostTree addNode:parent];
    [hostTree addEdgeFromNode:parent toNode:ghost withIndex:j];
  }
  [hostTree copyTree:templateTree toReplaceNode:ghost];
  
  [hostTree configureNodes];
  [hostTree setPropagateNewParentExpressions:YES];
  
  return hostTree;
}

+ (IFTemplateLayer*)layerForTemplate:(IFTreeTemplate*)theTreeTemplate;
{
  return [[[self alloc] initForTemplate:theTreeTemplate] autorelease];
}

- (IFTemplateLayer*)initForTemplate:(IFTreeTemplate*)theTreeTemplate;
{
  if (![super init])
    return nil;
  
  treeTemplate = [theTreeTemplate retain];

  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  // Artiy indicator layer
  if (treeTemplate.tree.holesCount > 0) {
    arityIndicatorLayer = [CALayer layer];
    arityIndicatorLayer.needsDisplayOnBoundsChange = YES;
    arityIndicatorLayer.delegate = self;
    [arityIndicatorLayer setNeedsDisplay];
    [self addSublayer:arityIndicatorLayer];
  }
  
  // Normal mode layer
  normalModeTree = [computeNormalModeTreeForTemplate(treeTemplate) retain];
  normalNodeCompositeLayer = [IFNodeCompositeLayer layerForNode:normalModeTree.root ofTree:normalModeTree canvasBounds:normalCanvasBoundsVar];
  [self addSublayer:normalNodeCompositeLayer];
  
  nodeCompositeLayer = normalNodeCompositeLayer;
  
  // Name layer
  nameLayer = [CATextLayer layer];
  nameLayer.foregroundColor = layoutParameters.templateLabelColor;
  nameLayer.font = layoutParameters.labelFont;
  nameLayer.fontSize = layoutParameters.labelFont.pointSize;
  nameLayer.alignmentMode = kCAAlignmentCenter;
  nameLayer.truncationMode = kCATruncationMiddle;
  nameLayer.string = treeTemplate.name;
  [self addSublayer:nameLayer];

  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(normalNodeCompositeLayer);
  OBJC_RELEASE(normalModeTree);
  OBJC_RELEASE(treeTemplate);
  [super dealloc];
}

@synthesize treeTemplate;
@synthesize nodeCompositeLayer;

- (NSImage*)dragImage;
{
  return ((IFNodeLayer*)self.nodeCompositeLayer.baseLayer).dragImage;
}

- (CGSize)preferredFrameSize;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  return CGSizeMake(layoutParameters.columnWidth, [nameLayer preferredFrameSize].height + 2.0 + [nodeCompositeLayer preferredFrameSize].height);
}

- (void)layoutSublayers;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  const float nameHeight = [nameLayer preferredFrameSize].height;
  nameLayer.frame = (CGRect) { CGPointZero, CGSizeMake(layoutParameters.columnWidth, nameHeight) };
  
  nodeCompositeLayer.frame = (CGRect) { CGPointMake(0, nameHeight + 2.0), [nodeCompositeLayer preferredFrameSize] };
  arityIndicatorLayer.frame = (CGRect) { CGPointMake(0, CGRectGetMaxY(nodeCompositeLayer.frame)), CGSizeMake(layoutParameters.columnWidth, layoutParameters.connectorArrowSize) };

  if (!CGSizeEqualToSize(self.frame.size, [self preferredFrameSize]))
    [self.superlayer setNeedsLayout];
}

// delegate methods
- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;
{
  NSAssert(layer == arityIndicatorLayer, @"unexpected layer");
  
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float arrowSize = layoutParameters.connectorArrowSize;

  CGContextBeginPath(ctx);
  
  // Draw "arrow"
  CGContextMoveToPoint(ctx, 2.0 * layoutParameters.nodeInternalMargin, 0);
  CGContextAddLineToPoint(ctx, layoutParameters.nodeInternalMargin, arrowSize);
  CGContextAddLineToPoint(ctx, layoutParameters.columnWidth - layoutParameters.nodeInternalMargin, arrowSize);
  CGContextAddLineToPoint(ctx, layoutParameters.columnWidth - 2.0 * layoutParameters.nodeInternalMargin, 0);
  CGContextClosePath(ctx);

  // Draw dents
  const float dentWidth = 2.0;
  const unsigned dentsCount = treeTemplate.tree.holesCount - 1;
  const float dentSpacing = layoutParameters.columnWidth / (dentsCount + 1);
  float x = dentSpacing;
  for (unsigned i = 0; i < dentsCount; ++i) {
    CGContextAddRect(ctx, CGRectMake(round(x - dentWidth / 2.0), 0, dentWidth, arrowSize));
    x += dentSpacing;
  }

  CGContextSetFillColorWithColor(ctx, layoutParameters.connectorColor);
  CGContextEOFillPath(ctx);
}

@end
