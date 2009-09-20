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

typedef enum {
  IFVisibilityFlagTypeCorrect = 0x01,
  IFVisibilityFlagNotFiltered = 0x02,
} IFVisibilityFlag;

static const unsigned IFVisibilityFlagsVisible = IFVisibilityFlagTypeCorrect | IFVisibilityFlagNotFiltered;

@interface IFTemplateLayer ()
@property(retain) IFTree* normalModeTree;
@property(retain) IFTree* previewModeTree;
@property unsigned visibilityFlags;
@property(retain) IFNodeCompositeLayer* previewNodeCompositeLayer;
@end

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
  IFTreeNode* ghost = [IFTreeNode ghostNode];
  [hostTree addNode:ghost];
  for (int j = 0; j < parentsCount; ++j) {
    IFTreeNode* parent = [IFTreeNode universalSourceWithIndex:j];
    [hostTree addNode:parent];
    [hostTree addEdgeFromNode:parent toNode:ghost withIndex:j];
  }
  [hostTree cloneTree:templateTree toReplaceNode:ghost];
  
  [hostTree configureNodes];
  [hostTree setPropagateNewParentExpressions:YES];
  
  return hostTree;
}

+ (IFTemplateLayer*)layerForTemplate:(IFTreeTemplate*)theTreeTemplate layoutParameters:(IFLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initForTemplate:theTreeTemplate layoutParameters:theLayoutParameters] autorelease];
}

- (IFTemplateLayer*)initForTemplate:(IFTreeTemplate*)theTreeTemplate layoutParameters:(IFLayoutParameters*)theLayoutParameters;
{
  if (![super init])
    return nil;
  
  treeTemplate = [theTreeTemplate retain];
  layoutParameters = [theLayoutParameters retain];
  
  // Artiy indicator layer
  if (treeTemplate.tree.holesCount > 0) {
    arityIndicatorLayer = [CALayer layer];
    arityIndicatorLayer.needsDisplayOnBoundsChange = YES;
    arityIndicatorLayer.delegate = self;
    [arityIndicatorLayer setNeedsDisplay];
    [self addSublayer:arityIndicatorLayer];
  }
  
  // Node layer
  self.normalModeTree = computeNormalModeTreeForTemplate(treeTemplate);
  normalNodeCompositeLayer = [[IFNodeCompositeLayer layerForNode:normalModeTree.root ofTree:normalModeTree layoutParameters:layoutParameters canvasBounds:normalCanvasBoundsVar] retain];
  [self addSublayer:normalNodeCompositeLayer];
  
  // Name layer
  nameLayer = [CATextLayer layer];
  nameLayer.foregroundColor = [IFLayoutParameters templateLabelColor];
  nameLayer.font = [IFLayoutParameters labelFont];
  nameLayer.fontSize = [IFLayoutParameters labelFont].pointSize;
  nameLayer.alignmentMode = kCAAlignmentCenter;
  nameLayer.truncationMode = kCATruncationMiddle;
  nameLayer.string = treeTemplate.name;
  [self addSublayer:nameLayer];
  
  self.anchorPoint = CGPointZero;
  self.hidden = NO;
  visibilityFlags = IFVisibilityFlagsVisible;
  
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(previewNodeCompositeLayer);
  OBJC_RELEASE(previewModeTree);
  OBJC_RELEASE(normalNodeCompositeLayer);
  OBJC_RELEASE(normalModeTree);
  OBJC_RELEASE(layoutParameters);
  OBJC_RELEASE(treeTemplate);
  [super dealloc];
}

@synthesize treeTemplate;

- (IFTree*)tree;
{
  return (previewModeTree == nil) ? normalModeTree : previewModeTree;
}

- (IFTreeNode*)treeNode;
{
  return self.nodeCompositeLayer.node;
}

- (void)switchToPreviewModeForNode:(IFTreeNode*)node ofTree:(IFTree*)tree canvasBounds:(IFVariable*)canvasBoundsVar;
{
  // Create preview tree
  self.previewModeTree = [tree cloneWithoutNewParentExpressionsPropagation];
  NSSet* constNodes = [NSSet setWithSet:previewModeTree.nodes];
  IFTreeNode* previewTreeNode = [previewModeTree cloneTree:treeTemplate.tree toReplaceNode:node];  
  if ([previewModeTree isTypeCorrect]) {
    [previewModeTree configureAllNodesBut:constNodes];
    self.previewNodeCompositeLayer = [IFNodeCompositeLayer layerForNode:previewTreeNode ofTree:previewModeTree layoutParameters:layoutParameters canvasBounds:canvasBoundsVar];
    
    [self replaceSublayer:normalNodeCompositeLayer with:previewNodeCompositeLayer];
    self.visibilityFlags = self.visibilityFlags | IFVisibilityFlagTypeCorrect;
  } else
    self.visibilityFlags = self.visibilityFlags & ~IFVisibilityFlagTypeCorrect;
}

- (void)switchToNormalMode;
{
  if (previewNodeCompositeLayer != nil) {
    [self replaceSublayer:previewNodeCompositeLayer with:normalNodeCompositeLayer];
    self.previewNodeCompositeLayer = nil;
  }
  
  self.hidden = NO;
  self.visibilityFlags = IFVisibilityFlagsVisible;
}

- (BOOL)filterOut;
{
  return (visibilityFlags & IFVisibilityFlagNotFiltered) == 0;
}

- (void)setFilterOut:(BOOL)newFilterOut;
{
  if (newFilterOut == self.filterOut)
    return;
  self.visibilityFlags = self.visibilityFlags ^ IFVisibilityFlagNotFiltered;
}

- (IFNodeCompositeLayer*)nodeCompositeLayer;
{
  return (previewNodeCompositeLayer == nil) ? normalNodeCompositeLayer : previewNodeCompositeLayer;
}

@synthesize nameLayer;

- (NSImage*)dragImage;
{
  return ((IFNodeLayer*)self.nodeCompositeLayer.baseLayer).dragImage;
}

- (void)layoutSublayers;
{
  const float totalWidth = CGRectGetWidth(self.nodeCompositeLayer.bounds);
  
  nameLayer.frame = CGRectMake(0, 0, totalWidth, [nameLayer preferredFrameSize].height);

  IFNodeCompositeLayer* nodeLayer = self.nodeCompositeLayer;
  nodeLayer.frame = (CGRect) { CGPointMake(0, CGRectGetMaxY(nameLayer.frame)), nodeLayer.bounds.size };

  arityIndicatorLayer.frame = CGRectMake(0, CGRectGetMaxY(nodeLayer.frame), totalWidth, [IFLayoutParameters connectorArrowSize]);

  self.bounds = CGRectMake(0, 0, totalWidth, CGRectGetMaxY(arityIndicatorLayer.frame));
  [self.superlayer setNeedsLayout];
}

// MARK: Delegate methods

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;
{
  NSAssert(layer == arityIndicatorLayer, @"unexpected layer");
  
  const float arrowSize = [IFLayoutParameters connectorArrowSize];
  const float margin = [IFLayoutParameters nodeInternalMargin];

  CGContextBeginPath(ctx);
  
  // Draw "arrow"
  CGContextMoveToPoint(ctx, 2.0 * margin, 0);
  CGContextAddLineToPoint(ctx, margin, arrowSize);
  CGContextAddLineToPoint(ctx, CGRectGetWidth(layer.bounds) - margin, arrowSize);
  CGContextAddLineToPoint(ctx, CGRectGetWidth(layer.bounds) - 2.0 * margin, 0);
  CGContextClosePath(ctx);

  // Draw dents
  const float dentWidth = 2.0;
  const unsigned dentsCount = treeTemplate.tree.holesCount - 1;
  const float dentSpacing = CGRectGetWidth(layer.bounds) / (dentsCount + 1);
  float x = dentSpacing;
  for (unsigned i = 0; i < dentsCount; ++i) {
    CGContextAddRect(ctx, CGRectMake(round(x - dentWidth / 2.0), 0, dentWidth, arrowSize));
    x += dentSpacing;
  }

  CGContextSetFillColorWithColor(ctx, [IFLayoutParameters connectorColor]);
  CGContextEOFillPath(ctx);
}

// -
// MARK: PRIVATE

@synthesize normalModeTree, previewModeTree;
@synthesize visibilityFlags;

- (void)setVisibilityFlags:(unsigned)newVisibiltyFlags;
{
  visibilityFlags = newVisibiltyFlags;
  self.hidden = (visibilityFlags != IFVisibilityFlagsVisible);
}

@synthesize previewNodeCompositeLayer;

@end
