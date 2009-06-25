//
//  IFImageOrMaskLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFImageOrMaskLayer.h"
#import "IFOperatorExpression.h"
#import "IFExpressionEvaluator.h"

@implementation IFImageOrMaskLayer

static NSString* IFCanvasBoundsChangedContext = @"IFCanvasBoundsChangedContext";
static NSString* IFThumbnailWidthChangedContext = @"IFThumbnailWidthChangedContext";

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super init])
    return nil;
  
  layoutParameters = [theLayoutParameters retain];
  canvasBoundsVar = [theCanvasBoundsVar retain];
  
  self.anchorPoint = CGPointZero;
  self.needsDisplayOnBoundsChange = YES;
  
  maskIndicatorLayer = [IFStaticImageLayer layerWithImageNamed:@"mask_tag"];
  maskIndicatorLayer.frame = CGRectMake(CGRectGetWidth(self.frame) - maskIndicatorLayer.imageSize.width, 0, maskIndicatorLayer.imageSize.width, maskIndicatorLayer.imageSize.height);
  maskIndicatorLayer.autoresizingMask = kCALayerMinXMargin | kCALayerMaxYMargin; // stick to bottom-right edge
  maskIndicatorLayer.hidden = YES;
  [self addSublayer:maskIndicatorLayer];

  [canvasBoundsVar addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionInitial context:IFCanvasBoundsChangedContext];
  [layoutParameters addObserver:self forKeyPath:@"thumbnailWidth" options:NSKeyValueObservingOptionInitial context:IFThumbnailWidthChangedContext];

  return self;
}

- (void)dealloc;
{
  // If canvasBoundsVar is nil, this is a presentation layer (there doesn't seem to be a better way to know this currently)
  if (canvasBoundsVar != nil) {
    OBJC_RELEASE(expression);
    [canvasBoundsVar removeObserver:self forKeyPath:@"value"];
    OBJC_RELEASE(canvasBoundsVar);
    [layoutParameters removeObserver:self forKeyPath:@"thumbnailWidth"];
    OBJC_RELEASE(layoutParameters);
  }
  [super dealloc];
}

- (void)setExpression:(IFConstantExpression*)newExpression;
{
  NSAssert(newExpression == nil || [newExpression isImage], @"invalid expression");
  
  if (newExpression == expression)
    return;
  [expression release];
  expression = [newExpression retain];
  
  maskIndicatorLayer.hidden = (((IFImageConstantExpression*)expression).image.kind != IFImageKindMask);
  [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx;
{
  const IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  const NSRect canvasBounds = ((NSValue*)canvasBoundsVar.value).rectValue;
  const float scaling = CGRectGetWidth(self.bounds) / NSWidth(canvasBounds);
  const IFImageConstantExpression* imageExpression = (IFImageConstantExpression*)[evaluator evaluateExpression:[IFOperatorExpression resample:[IFOperatorExpression crop:[evaluator evaluateExpressionAsImage:expression] along:canvasBounds] by:scaling]];
  CIImage* image = [imageExpression imageValueCI];
  
  CIContext* ciContext = [CIContext contextWithCGContext:ctx options:[NSDictionary dictionary]]; // TODO: working color space
  CGRect sourceRect = CGRectMake(CGRectGetMinX(image.extent), CGRectGetMinY(image.extent), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
  [ciContext drawImage:image inRect:self.bounds fromRect:sourceRect];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFCanvasBoundsChangedContext || context == IFThumbnailWidthChangedContext) {
    const NSSize canvasSize = ((NSValue*)canvasBoundsVar.value).rectValue.size;
    const float thumbnailWidth = layoutParameters.thumbnailWidth;
    self.bounds = CGRectMake(0, 0, thumbnailWidth, floor(thumbnailWidth * (canvasSize.height / canvasSize.width)));
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
