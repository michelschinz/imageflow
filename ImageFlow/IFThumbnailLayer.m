//
//  IFThumbnailLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.09.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFThumbnailLayer.h"

#import "IFOperatorExpression.h"
#import "IFErrorConstantExpression.h"
#import "IFImageConstantExpression.h"
#import "IFLayoutParameters.h"

@interface IFThumbnailLayer (Private)
@property(retain) IFConstantExpression* evaluatedExpression;
@property float aspectRatio;
- (void)updateEvaluatedExpression;
@end

@implementation IFThumbnailLayer

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";
static NSString* IFCanvasBoundsChangedContext = @"IFCanvasBoundsChangedContext";
static NSString* IFColumnWidthChangedContext = @"IFColumnWidthChangedContext";

static CGImageRef errorImage;
static CGImageRef aliasImage;
static CGImageRef maskImage;

static CGImageRef imageNamed(NSString* imageName) {
  NSString* path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
  NSURL* url = [NSURL fileURLWithPath:path];
  
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, (CFDictionaryRef)[NSDictionary dictionary]);
  CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)[NSDictionary dictionary]);
  CFRelease(imageSource);
  
  return image;
}

+ (void)initialize;
{
  if (self != [IFThumbnailLayer class])
    return; // avoid repeated initialisation

  errorImage = imageNamed(@"warning-sign");
  aliasImage = imageNamed(@"alias_arrow");
  maskImage = imageNamed(@"mask_tag");
}

+ (id)layerForNode:(IFTreeNode*)theNode;
{
  return [[[self alloc] initForNode:theNode] autorelease];
}

- (id)initForNode:(IFTreeNode*)theNode;
{
  if (![super init])
    return nil;

  NSAssert(theNode != nil, @"nil node");
  node = [theNode retain];
  
  self.needsDisplayOnBoundsChange = YES;
  // TODO: maybe set opaque to YES (but then fix problem with error sign, e.g. by setting a background color)
  
  // Create and add sublayers
  if (theNode.isAlias) {
    aliasArrowLayer = [CALayer layer];
    aliasArrowLayer.frame = CGRectMake(0, 0, CGImageGetWidth(aliasImage), CGImageGetHeight(aliasImage));
    aliasArrowLayer.autoresizingMask = kCALayerMaxXMargin | kCALayerMaxYMargin; // stick to bottom-left edge
    aliasArrowLayer.contents = (id)aliasImage;
    [self addSublayer:aliasArrowLayer];
  }
  
  maskIndicatorLayer = [CALayer layer];
  maskIndicatorLayer.frame = CGRectMake(CGRectGetWidth(self.frame) - CGImageGetWidth(maskImage), 0, CGImageGetWidth(maskImage), CGImageGetHeight(maskImage));
  maskIndicatorLayer.autoresizingMask = kCALayerMinXMargin | kCALayerMaxYMargin; // stick to bottom-right edge
  maskIndicatorLayer.contents = (id)maskImage;
  maskIndicatorLayer.hidden = YES;
  [self addSublayer:maskIndicatorLayer];
  
  [self updateEvaluatedExpression];
  
  [[IFLayoutParameters sharedLayoutParameters] addObserver:self forKeyPath:@"columnWidth" options:0 context:IFColumnWidthChangedContext];
  // TODO: observe canvas bounds
  [node addObserver:self forKeyPath:@"expression" options:0 context:IFExpressionChangedContext];

  return self;
}

- (void)dealloc;
{
  // If node is nil, this is a presentation layer (there doesn't seem to be a better way to know this currently)
  if (node != nil) {
    [node removeObserver:self forKeyPath:@"expression"];
    [[IFLayoutParameters sharedLayoutParameters] removeObserver:self forKeyPath:@"columnWidth"];
  
    OBJC_RELEASE(node);
    OBJC_RELEASE(evaluatedExpression);
  }
  [super dealloc];
}

- (CGSize)preferredFrameSize;
{
  if (aspectRatio == 0.0)
    return CGSizeZero;
  else {
    const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
    const float width = layoutParameters.columnWidth - 2.0 * layoutParameters.nodeInternalMargin;
    return CGSizeMake(width, width / aspectRatio);
  }
}

- (void)drawInContext:(CGContextRef)ctx;
{
  if (!evaluatedExpression.isError) {
    IFImageConstantExpression* imageExpression = (IFImageConstantExpression*)evaluatedExpression;
    
    CIContext* ciContext = [CIContext contextWithCGContext:ctx options:[NSDictionary dictionary]]; // TODO: working color space
    CIImage* image = imageExpression.imageValueCI;
    CGRect sourceRect = CGRectMake(CGRectGetMinX(image.extent), CGRectGetMinY(image.extent), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [ciContext drawImage:image inRect:self.bounds fromRect:sourceRect];
  } else {
    IFErrorConstantExpression* errorExpression = (IFErrorConstantExpression*)evaluatedExpression;
    if (errorExpression.message != nil) {
      const float x = floor((CGRectGetWidth(self.bounds) - CGImageGetWidth(errorImage)) / 2.0);
      CGContextDrawImage(ctx, CGRectMake(x, 0, CGImageGetWidth(errorImage), CGImageGetHeight(errorImage)), errorImage);
    } else
      ; // nothing to draw
  }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFColumnWidthChangedContext) {
    [self updateEvaluatedExpression];
    [self.superlayer setNeedsLayout];
  } else if (context == IFExpressionChangedContext || context == IFCanvasBoundsChangedContext)
    [self updateEvaluatedExpression];
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end

@implementation IFThumbnailLayer (Private)

- (void)setEvaluatedExpression:(IFConstantExpression*)newExpression;
{
  if (newExpression == evaluatedExpression)
    return;
  [evaluatedExpression release];
  evaluatedExpression = [newExpression retain];
  
  [self setNeedsDisplay];
}

- (IFConstantExpression*)evaluatedExpression;
{
  return evaluatedExpression;
}

- (void)setAspectRatio:(float)newAspectRatio;
{
  if (fabs(newAspectRatio - aspectRatio) > 0.01)
    [self.superlayer setNeedsLayout];

  aspectRatio = newAspectRatio;
}

- (float)aspectRatio;
{
  return aspectRatio;
}

- (void)updateEvaluatedExpression;
{
  const IFLayoutParameters* layoutParameters = [IFLayoutParameters sharedLayoutParameters];
  const float margin = layoutParameters.nodeInternalMargin;
  
  IFExpression* nodeExpression = node.expression;
  if (nodeExpression == nil)
    return;
  
  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  IFConstantExpression* basicExpression = [evaluator evaluateExpression:nodeExpression];
  if (!basicExpression.isError) {
    CGRect canvasBounds = layoutParameters.canvasBounds;
    IFExpression* imageExpression = [evaluator evaluateExpressionAsImage:basicExpression];
    IFExpression* croppedExpression = [IFOperatorExpression crop:imageExpression along:NSRectFromCGRect(canvasBounds)];
    const float maxSide = layoutParameters.columnWidth - 2.0 * margin;
    const float scaling = maxSide / fmax(CGRectGetWidth(canvasBounds), CGRectGetHeight(canvasBounds));
    IFExpression* scaledCroppedExpression = [IFOperatorExpression resample:croppedExpression by:scaling];
    self.evaluatedExpression = [evaluator evaluateExpression:scaledCroppedExpression];
    self.aspectRatio = CGRectIsEmpty(canvasBounds) ? 0.0 : CGRectGetWidth(canvasBounds) / CGRectGetHeight(canvasBounds);
    
    maskIndicatorLayer.hidden = (((IFImageConstantExpression*)basicExpression).image.kind != IFImageKindMask);
  } else {
    self.evaluatedExpression = basicExpression;
    
    IFErrorConstantExpression* errorExpression = (IFErrorConstantExpression*)basicExpression;
    if (errorExpression.message != nil)
      self.aspectRatio = (layoutParameters.columnWidth - 2.0 * layoutParameters.nodeInternalMargin) / CGImageGetHeight(errorImage);
    else
      self.aspectRatio = 0.0;
    
    maskIndicatorLayer.hidden = YES;
  }
}

@end
