//
//  IFImageOrMaskLayer.m
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFImageOrMaskLayer.h"
#import "IFExpression.h"
#import "IFExpressionEvaluator.h"
#import "IFBlendMode.h"

@implementation IFImageOrMaskLayer

static NSString* IFCanvasBoundsChangedContext = @"IFCanvasBoundsChangedContext";
static NSString* IFThumbnailWidthChangedContext = @"IFThumbnailWidthChangedContext";
static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";

+ (id)layerWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  return [[[self alloc] initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar] autorelease];
}

- (id)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;
{
  if (![super initWithLayoutParameters:theLayoutParameters canvasBounds:theCanvasBoundsVar])
    return nil;
  
  borderHighlighted = NO;
  
  self.anchorPoint = CGPointZero;
  self.needsDisplayOnBoundsChange = YES;
  self.borderWidth = 1.0;
  self.borderColor = [IFLayoutParameters thumbnailBorderColor];
  
  maskIndicatorLayer = [IFStaticImageLayer layerWithImageNamed:@"mask_tag"];
  maskIndicatorLayer.position = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(maskIndicatorLayer.bounds), 0);
  maskIndicatorLayer.autoresizingMask = kCALayerMinXMargin | kCALayerMaxYMargin; // stick to bottom-right edge
  maskIndicatorLayer.hidden = YES;
  [self addSublayer:maskIndicatorLayer];

  [canvasBoundsVar addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionInitial context:IFCanvasBoundsChangedContext];
  [layoutParameters addObserver:self forKeyPath:@"thumbnailWidth" options:NSKeyValueObservingOptionInitial context:IFThumbnailWidthChangedContext];
  [self addObserver:self forKeyPath:@"expression" options:0 context:IFExpressionChangedContext];

  return self;
}

- (void)dealloc;
{
  // If canvasBoundsVar is nil, this is a presentation layer (there doesn't seem to be a better way to know this currently)
  if (canvasBoundsVar != nil) {
    [self removeObserver:self forKeyPath:@"expression"];
    [canvasBoundsVar removeObserver:self forKeyPath:@"value"];
    [layoutParameters removeObserver:self forKeyPath:@"thumbnailWidth"];
  }
  [super dealloc];
}

- (NSArray*)thumbnailLayers;
{
  return [NSArray arrayWithObject:self];
}

@synthesize borderHighlighted;
- (void)setBorderHighlighted:(BOOL)newValue;
{
  self.borderColor = newValue ? [IFLayoutParameters displayedThumbnailBorderColor] : [IFLayoutParameters thumbnailBorderColor];
  borderHighlighted = newValue;
}

- (void)drawInContext:(CGContextRef)ctx;
{
  const IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  
  IFConstantExpression* imageOrMaskExpr = [evaluator evaluateExpression:expression];
  NSAssert([imageOrMaskExpr isImage], @"unexpected expression");

  IFExpression* imageExpr;
  switch (imageOrMaskExpr.imageValue.kind) {
    case IFImageKindRGBImage: {      
      IFExpression* backgroundExpr = [IFExpression checkerboardCenteredAt:NSZeroPoint color0:[NSColor whiteColor] color1:[NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.8 alpha:1.0] width:40.0 sharpness:1.0]; // TODO: replace by user-settable expression
      imageExpr = [IFExpression blendBackground:backgroundExpr withForeground:expression inMode:[IFConstantExpression expressionWithInt:IFBlendMode_SourceOver]];
      maskIndicatorLayer.hidden = YES;
    } break;
    case IFImageKindMask: {
      imageExpr = [IFExpression maskToImage:expression];
      maskIndicatorLayer.hidden = NO;
    } break;
    default:
      NSAssert(NO, @"unexpected image kind");
      break;
  }

  const NSRect canvasBounds = ((NSValue*)canvasBoundsVar.value).rectValue;
  const float scaling = CGRectGetWidth(self.bounds) / NSWidth(canvasBounds);
  const IFConstantExpression* imageExpression = [evaluator evaluateExpression:[IFExpression resample:[IFExpression crop:imageExpr along:canvasBounds] by:scaling]];
  CIImage* image = imageExpression.imageValue.imageCI;
  
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
  } else if (context == IFExpressionChangedContext) {
    [self setNeedsDisplay];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
