//
//  IFTemplateLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFTemplateLayer.h"

#import "IFLayoutParameters.h"

@implementation IFTemplateLayer

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
    arityIndicatorLayer.delegate = self;
    [arityIndicatorLayer setNeedsDisplay];
    [self addSublayer:arityIndicatorLayer];
  }
  
  // Normal mode layer
  normalModeTree = [computeNormalModeTreeForTemplate(treeTemplate) retain];
  normalNodeCompositeLayer = [IFNodeCompositeLayer layerForNode:normalModeTree.root];
  [self addSublayer:normalNodeCompositeLayer];
  
  nodeCompositeLayer = normalNodeCompositeLayer;
  
  // Name layer
  nameLayer = [CATextLayer layer];
  nameLayer.foregroundColor = layoutParameters.nodeLabelColor;
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

- (CGSize)preferredFrameSize;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  return CGSizeMake(layoutParameters.columnWidth, [nameLayer preferredFrameSize].height + [nodeCompositeLayer preferredFrameSize].height);
}

- (void)layoutSublayers;
{
  IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  
  const float nameHeight = [nameLayer preferredFrameSize].height;
  nameLayer.frame = (CGRect) { CGPointZero, CGSizeMake(layoutParameters.columnWidth, nameHeight) };
  
  nodeCompositeLayer.frame = (CGRect) { CGPointMake(0, nameHeight), [nodeCompositeLayer preferredFrameSize] };
  arityIndicatorLayer.frame = (CGRect) { CGPointMake(0, CGRectGetMaxY(nodeCompositeLayer.frame)), CGSizeMake(layoutParameters.columnWidth, layoutParameters.connectorArrowSize) };
}

// delegate methods
- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;
{
  NSAssert(layer == arityIndicatorLayer, @"unexpected layer");
  
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float arrowSize = layoutParameters.connectorArrowSize;

  CGContextBeginPath(ctx);
  
  // Draw "arrow"
  CGContextMoveToPoint(ctx, arrowSize, 0);
  CGContextAddLineToPoint(ctx, 0, arrowSize);
  CGContextAddLineToPoint(ctx, layoutParameters.columnWidth, arrowSize);
  CGContextAddLineToPoint(ctx, layoutParameters.columnWidth - arrowSize, 0);
  CGContextClosePath(ctx);

  // Draw dents
  const float dentWidth = 2.0;
  const unsigned dentsCount = treeTemplate.tree.holesCount - 1;
  const float dentSpacing = layoutParameters.columnWidth / (dentsCount + 1);
  float x = dentSpacing;
  for (unsigned i = 0; i < dentsCount; ++i) {
    CGContextAddRect(ctx, CGRectMake(x - dentWidth / 2.0, 0, dentWidth, arrowSize));
    x += dentSpacing;
  }

  CGContextSetFillColorWithColor(ctx, layoutParameters.connectorColor);
  CGContextEOFillPath(ctx);
}

@end
