//
//  IFNodeLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 10.07.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFNodeLayer.h"
#import "IFImageOrMaskLayer.h"
#import "IFStackLayer.h"
#import "IFErrorLayer.h"

@interface IFNodeLayer()
- (void)setExpression:(IFExpression*)newUnevaluatedExpression;
@property(readwrite, assign, nonatomic) IFExpressionContentsLayer* expressionLayer;
@end

@implementation IFNodeLayer

static NSString* IFNodeLabelChangedContext = @"IFNodeLabelChangedContext";
static NSString* IFNodeNameChangedContext = @"IFNodeNameChangedContext";
static NSString* IFNodeFoldingStateChangedContext = @"IFNodeFoldingStateChangedContext";
static NSString* IFNodeExpressionChangedContext = @"IFNodeExpressionChangedContext";

+ (id)layerForNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithNode:theNode ofTree:theTree layoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode ofTree:(IFTree*)theTree layoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super init])
    return nil;

  node = [theNode retain];
  tree = [theTree retain];
  layoutParameters = [theLayoutParameters retain];
  canvasBounds = [theCanvasBoundsVar retain];
  
  self.style = [IFLayoutParameters nodeLayerStyle];
  
  // Label
  labelLayer = [CATextLayer layer];
  labelLayer.font = [IFLayoutParameters labelFont];
  labelLayer.fontSize = [IFLayoutParameters labelFont].pointSize;
  labelLayer.foregroundColor = [IFLayoutParameters nodeLabelColor];
  labelLayer.alignmentMode = kCAAlignmentCenter;
  labelLayer.truncationMode = kCATruncationMiddle;
  [self addSublayer:labelLayer];
  
  // Alias arrow
  if ([node isAlias]) {
    aliasArrowLayer = [IFStaticImageLayer layerWithImageNamed:@"alias_arrow"];
    [self addSublayer:aliasArrowLayer];
  } else
    aliasArrowLayer = nil;
  
  // Folding separator
  foldingSeparatorLayer = [CALayer layer];
  foldingSeparatorLayer.needsDisplayOnBoundsChange = YES;
  foldingSeparatorLayer.delegate = self;
  [self addSublayer:foldingSeparatorLayer];
  
  // Expression thumbnail
  expressionLayer = nil;
  
  // Name
  nameLayer = [CATextLayer layer];
  nameLayer.font = [IFLayoutParameters labelFont];
  nameLayer.fontSize = [IFLayoutParameters labelFont].pointSize;
  nameLayer.foregroundColor = labelLayer.foregroundColor;
  nameLayer.alignmentMode = kCAAlignmentCenter;
  nameLayer.truncationMode = kCATruncationMiddle;
  [self addSublayer:nameLayer];
  
  [node addObserver:self forKeyPath:@"label" options:NSKeyValueObservingOptionInitial context:IFNodeLabelChangedContext];
  [node addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionInitial context:IFNodeNameChangedContext];
  [node addObserver:self forKeyPath:@"isFolded" options:NSKeyValueObservingOptionInitial context:IFNodeFoldingStateChangedContext];
  [node addObserver:self forKeyPath:@"expression" options:NSKeyValueObservingOptionInitial context:IFNodeExpressionChangedContext];
  
  return self;
}

- (void)dealloc;
{
  [node removeObserver:self forKeyPath:@"expression"];
  [node removeObserver:self forKeyPath:@"isFolded"];
  [node removeObserver:self forKeyPath:@"name"];
  [node removeObserver:self forKeyPath:@"label"];
  
  OBJC_RELEASE(canvasBounds);
  OBJC_RELEASE(layoutParameters);
  OBJC_RELEASE(tree);
  OBJC_RELEASE(node);
  [super dealloc];
}

@synthesize node;

@synthesize labelLayer, expressionLayer, nameLayer;

- (NSArray*)thumbnailLayers;
{
  return (expressionLayer != nil) ? expressionLayer.thumbnailLayers : [NSArray array];
}

- (void)layoutSublayers;
{
  const float internalMargin = [IFLayoutParameters nodeInternalMargin];

  const float x = internalMargin;
  float y = internalMargin;
  const float expressionWidth = fmax(layoutParameters.thumbnailWidth, expressionLayer != nil ? CGRectGetWidth(expressionLayer.bounds) : 0.0);
  const float totalWidth = expressionWidth + 2.0 * internalMargin;
  
  if (nameLayer.string != nil) {
    nameLayer.frame = CGRectMake(x, y, expressionWidth, nameLayer.preferredFrameSize.height);
    y += CGRectGetHeight(nameLayer.bounds) + internalMargin;
  }
  
  if (expressionLayer != nil) {
    expressionLayer.position = CGPointMake(x + round((expressionWidth - CGRectGetWidth(expressionLayer.bounds)) / 2.0), y);
    y += CGRectGetHeight(expressionLayer.bounds) + internalMargin;
  }
  
  foldingSeparatorLayer.frame = CGRectMake(0, y, totalWidth, 1.0);
  if (!foldingSeparatorLayer.hidden)
    y += CGRectGetHeight(foldingSeparatorLayer.bounds) + internalMargin;

  const float labelHeight = labelLayer.preferredFrameSize.height;
  float labelWidth = expressionWidth;
  if (aliasArrowLayer != nil) {
    aliasArrowLayer.position = CGPointMake(x + expressionWidth - CGRectGetWidth(aliasArrowLayer.bounds), y + floor((labelHeight - CGRectGetHeight(aliasArrowLayer.bounds)) / 2.0));
    labelWidth -= CGRectGetWidth(aliasArrowLayer.bounds) + internalMargin;
  }
  
  labelLayer.frame = CGRectMake(x, y, labelWidth, labelHeight);
  y += CGRectGetHeight(labelLayer.bounds) + internalMargin;
  
  self.bounds = CGRectMake(0, 0, totalWidth, y);
  [self.superlayer setNeedsLayout];
}

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx;
{
  NSAssert(layer == foldingSeparatorLayer, @"unexpected layer");

  CGContextSetLineWidth(ctx, 1.0);
  CGFloat dash[] = { 1.0, 1.0 };
  CGContextSetLineDash(ctx, 0, dash, sizeof(dash) / sizeof(CGFloat));
  CGContextSetStrokeColorWithColor(ctx, [IFLayoutParameters backgroundColor]);
  
  CGContextBeginPath(ctx);
  CGContextMoveToPoint(ctx, 0, 0);
  CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), 0);
  CGContextStrokePath(ctx);
}

// TODO: avoid code duplication with IFGhostNodeLayer.m
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

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFNodeFoldingStateChangedContext) {
    if (node.isFolded) {
      unsigned ancestors = [tree ancestorsCountOfNode:node];
      foldingSeparatorLayer.hidden = NO;
      labelLayer.string = [NSString stringWithFormat:@"(%d nodes)", ancestors];
      labelLayer.opacity = 0.5;
    } else {
      foldingSeparatorLayer.hidden = YES;
      labelLayer.string = node.label;
      labelLayer.opacity = 1.0;
    }
    [self.superlayer setNeedsLayout];
  } else if (context == IFNodeLabelChangedContext) {
    labelLayer.string = node.label;
  } else if (context == IFNodeNameChangedContext) {
    nameLayer.string = node.name;
  } else if (context == IFNodeExpressionChangedContext) {
    [self setExpression:node.expression];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

// MARK: -
// MARK: PRIVATE

- (void)setExpression:(IFExpression*)newUnevaluatedExpression;
{
  IFConstantExpression* newExpression = [[IFExpressionEvaluator sharedEvaluator] evaluateExpression:newUnevaluatedExpression];
  
  IFExpressionContentsLayer* currentExpressionLayer = self.expressionLayer;
  IFExpressionContentsLayer* newExpressionLayer;
  
  if (newExpression.isImage) {
    newExpressionLayer = (currentExpressionLayer != nil && [currentExpressionLayer isKindOfClass:[IFImageOrMaskLayer class]])
    ? currentExpressionLayer
    : [IFImageOrMaskLayer layerWithLayoutParameters:layoutParameters canvasBounds:canvasBounds];
  } else if (newExpression.isArray) {
    newExpressionLayer = (currentExpressionLayer != nil && [currentExpressionLayer isKindOfClass:[IFStackLayer class]])
    ? currentExpressionLayer
    : [IFStackLayer layerWithLayoutParameters:layoutParameters canvasBounds:canvasBounds];
  } else if (newExpression.isError) {
    if (newExpression.object != nil) {
      newExpressionLayer = (currentExpressionLayer != nil && [currentExpressionLayer isKindOfClass:[IFErrorLayer class]])
      ? currentExpressionLayer
      : [IFErrorLayer layerWithLayoutParameters:layoutParameters canvasBounds:canvasBounds];
    } else
      newExpressionLayer = nil;
  } else if (newExpression.isAction) {
    newExpressionLayer = nil;
  } else
    NSAssert(NO, @"unexpected expression");
  
  if (newExpressionLayer != nil) {
    newExpressionLayer.reversedPath = [IFArrayPath emptyPath];
    // Pass the unevaluated expression to the layer, to enable as many rewrite-base optimizations as possible
    newExpressionLayer.expression = newUnevaluatedExpression;
  }
  self.expressionLayer = newExpressionLayer;
}

- (void)setExpressionLayer:(IFExpressionContentsLayer*)newExpressionLayer;
{
  CALayer* currentExpressionLayer = self.expressionLayer;
  if (newExpressionLayer == currentExpressionLayer)
    return;
  else if (currentExpressionLayer == nil)
    [self addSublayer:newExpressionLayer];
  else if (newExpressionLayer == nil)
    [currentExpressionLayer removeFromSuperlayer];
  else
    [self replaceSublayer:currentExpressionLayer with:newExpressionLayer];
  expressionLayer = newExpressionLayer;
}

@end

