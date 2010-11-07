//
//  IFStackLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFStackLayer.h"
#import "IFNodeLayer.h"
#import "IFLayoutParameters.h"
#import "IFImageOrMaskLayer.h"
#import "IFErrorLayer.h"

@interface IFStackLayer()
- (void)updateComponentLayers;
@property(retain) NSArray* componentLayers;
@end

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";

@implementation IFStackLayer

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar])
    return nil;

  // TODO: replace all these colors by layout parameters
  CGColorRef bg = CGColorCreateGenericGray(0, 0.15);
  CGColorRef borderC = CGColorCreateGenericGray(0, 0.25);
  CGColorRef labelC = CGColorCreateGenericGray(0.3, 1.0);

  self.anchorPoint = CGPointZero;
  self.backgroundColor = bg;
  self.borderColor = borderC;
  self.borderWidth = 1.0;
  self.cornerRadius = [IFLayoutParameters nodeInternalMargin];

  // Setup sub-layers
  countLayer = [CATextLayer layer];
  countLayer.anchorPoint = CGPointZero;
  countLayer.font = [IFLayoutParameters labelFont];
  countLayer.fontSize = [IFLayoutParameters labelFont].pointSize;
  countLayer.foregroundColor = labelC;
  [self addSublayer:countLayer];

  [self addObserver:self forKeyPath:@"expression" options:0 context:IFExpressionChangedContext];

  return self;
}

- (void)dealloc;
{
  countLayer = nil;
  // If canvasBoundsVar is nil, this is a presentation layer (there doesn't seem to be a better way to know this currently)
  if (canvasBoundsVar != nil)
    [self removeObserver:self forKeyPath:@"expression"];
  [super dealloc];
}

- (NSArray*)thumbnailLayers;
{
  NSMutableArray* thumbnailLayers = [NSMutableArray array];
  for (IFExpressionContentsLayer* layer in self.componentLayers)
    [thumbnailLayers addObjectsFromArray:layer.thumbnailLayers];
  return thumbnailLayers;
}

- (void)layoutSublayers;
{
  const float xMargin = [IFLayoutParameters nodeInternalMargin];
  const float yMargin = xMargin;
  const CGSize countSize = [countLayer preferredFrameSize];

  float x = countSize.width + 2.0 * xMargin;
  float maxHeight = 0.0;
  for (CALayer* componentLayer in self.componentLayers) {
    componentLayer.frame = (CGRect) { CGPointMake(x, yMargin), componentLayer.bounds.size };
    x += CGRectGetWidth(componentLayer.bounds) + xMargin;
    maxHeight = fmax(maxHeight, CGRectGetHeight(componentLayer.bounds));
  }
  const float totalHeight = maxHeight + 2.0 * yMargin;

  self.bounds = CGRectMake(0, 0, x, totalHeight);
  countLayer.frame = CGRectMake(xMargin, (totalHeight - countSize.height) / 2.0, countSize.width, countSize.height);
  [self.superlayer setNeedsLayout];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFExpressionChangedContext)
    [self updateComponentLayers];
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

// MARK: -
// MARK: PRIVATE

- (void)updateComponentLayers;
{
  IFConstantExpression* evaluatedExpression = [[IFExpressionEvaluator sharedEvaluator] evaluateExpression:expression];

  NSArray* componentExpressions = [evaluatedExpression arrayValue];
  countLayer.string = [NSString stringWithFormat:@"%d",[componentExpressions count]];

  NSArray* recyclableLayers = self.componentLayers;
  NSMutableArray* newComponentLayers = [NSMutableArray arrayWithCapacity:[componentExpressions count]];
  unsigned i = 0;
  for (IFConstantExpression* componentExpression in componentExpressions) {
    CALayer* recyclableLayer = (i < [recyclableLayers count]) ? [recyclableLayers objectAtIndex:i] : nil;
    IFExpressionContentsLayer* newComponentLayer;

    if (componentExpression.isImage) {
      newComponentLayer = (recyclableLayer != nil && [recyclableLayer isKindOfClass:[IFImageOrMaskLayer class]])
      ? recyclableLayer
      : [IFImageOrMaskLayer layerWithLayoutParameters:layoutParameters canvasBounds:canvasBoundsVar];
    } else if (componentExpression.isArray) {
      newComponentLayer = (recyclableLayer != nil && [recyclableLayer isKindOfClass:[IFStackLayer class]])
      ? recyclableLayer
      : [IFStackLayer layerWithLayoutParameters:layoutParameters canvasBounds:canvasBoundsVar];
    } else if (componentExpression.isError) {
      newComponentLayer = (recyclableLayer != nil && [recyclableLayer isKindOfClass:[IFErrorLayer class]])
      ? recyclableLayer
      : [IFErrorLayer layerWithLayoutParameters:layoutParameters canvasBounds:canvasBoundsVar];
    } else
      NSAssert(NO, @"unexpected component expression");

    newComponentLayer.reversedPath = [IFArrayPath pathElementWithIndex:i next:reversedPath];
    // Pass unevaluated expression to enable as many rewrite optimisations as possible
    newComponentLayer.expression = [IFExpression arrayGet:expression index:i];
    [newComponentLayers addObject:newComponentLayer];
    ++i;
  }

  self.componentLayers = newComponentLayers;
}

- (NSArray*)componentLayers;
{
  const unsigned nonComponentLayersCount = 1;
  return [self.sublayers subarrayWithRange:NSMakeRange(nonComponentLayersCount, self.sublayers.count - nonComponentLayersCount)];
}

- (void)setComponentLayers:(NSArray*)newComponentLayers;
{
  NSArray* currentComponentLayers = self.componentLayers;

  unsigned i = 0;
  for (CALayer* newComponentLayer in newComponentLayers) {
    CALayer* currentComponentLayer = (i < currentComponentLayers.count) ? [currentComponentLayers objectAtIndex:i] : nil;
    if (newComponentLayer != currentComponentLayer) {
      if (currentComponentLayer != nil)
        [self replaceSublayer:currentComponentLayer with:newComponentLayer];
      else
        [self addSublayer:newComponentLayer];
    }
    ++i;
  }

  if (i < currentComponentLayers.count) {
    for (CALayer* layerToRemove in [currentComponentLayers subarrayWithRange:NSMakeRange(i, [currentComponentLayers count] - i)])
      [layerToRemove removeFromSuperlayer];
  }
}

@end
