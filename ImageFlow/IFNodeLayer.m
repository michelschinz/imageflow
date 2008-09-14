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

@interface IFNodeLayer (Private)
@property float thumbnailAspectRatio;
@property(retain) IFConstantExpression* evaluatedExpression;
- (void)updateExpression;
- (void)updateInternalLayout;
@end

@implementation IFNodeLayer

static NSString* IFExpressionChangedContext = @"IFExpressionChangedContext";
static NSString* IFCanvasBoundsChangedContext = @"IFCanvasBoundsChangedContext";
static NSString* IFColumnWidthChangedContext = @"IFColumnWidthChangedContext";

static NSImage* errorImage = nil;
static NSImage* maskImage = nil;
static NSImage* aliasImage = nil;

+ (void)initialize;
{
  if (self != [IFNodeLayer class])
    return; // avoid repeated initialisation
  errorImage = [NSImage imageNamed:@"warning-sign"];
  maskImage = [NSImage imageNamed:@"mask_tag"];
  aliasImage = [NSImage imageNamed:@"alias_arrow"];
}

+ (id)layerForNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  return [[[self alloc] initWithNode:theNode layoutParameters:theLayoutParameters] autorelease];
}

- (id)initWithNode:(IFTreeNode*)theNode layoutParameters:(IFTreeLayoutParameters*)theLayoutParameters;
{
  if (![super initForNode:theNode layoutParameters:theLayoutParameters])
    return nil;

  [self updateExpression];
  [self updateInternalLayout];
  
  [node addObserver:self forKeyPath:@"expression" options:0 context:IFExpressionChangedContext];
  [layoutParameters addObserver:self forKeyPath:@"canvasBounds" options:0 context:IFCanvasBoundsChangedContext];
  [layoutParameters addObserver:self forKeyPath:@"columnWidth" options:0 context:IFColumnWidthChangedContext];
  
  return self;
}

- (void)dealloc;
{
  [layoutParameters removeObserver:self forKeyPath:@"columnWidth"];
  [layoutParameters removeObserver:self forKeyPath:@"canvasBounds"];
  [node removeObserver:self forKeyPath:@"expression"];

  [super dealloc];
}

// MARK: properties

@synthesize node;

- (CGSize)preferredFrameSize;
{
  return NSSizeToCGSize(outlinePath.bounds.size);
}

- (NSImage*)dragImage;
{
  size_t width = round(CGRectGetWidth(self.bounds));
  size_t height = round(CGRectGetHeight(self.bounds));
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
  CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
  CGContextSetAlpha(ctx, 0.6);
  [self drawInContext:ctx];
  CGImageRef cgDragImage = CGBitmapContextCreateImage(ctx);
  NSImageRep* imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:cgDragImage] autorelease];
  CGImageRelease(cgDragImage);
  CGContextRelease(ctx);
  CGColorSpaceRelease(colorSpace);
  
  NSImage* dragImage = [[[NSImage alloc] init] autorelease];
  [dragImage addRepresentation:imageRep];
  return dragImage;
}

// MARK: misc.

- (void)drawInCurrentNSGraphicsContext;
{
  NSMutableParagraphStyle* parStyle = [NSMutableParagraphStyle new];
  [parStyle setAlignment:NSCenterTextAlignment];
  NSDictionary* textAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                             parStyle, NSParagraphStyleAttributeName,
                             layoutParameters.labelFont, NSFontAttributeName,
                             [NSColor blackColor], NSForegroundColorAttributeName,
                             nil];
  
  // Draw background path
  [[NSColor whiteColor] set];
  [self.outlinePath fill];
  
  // Draw label
  NSAttributedString* label = [[[NSAttributedString alloc] initWithString:node.label attributes:textAttrs] autorelease];
  [label drawWithRect:NSRectFromCGRect(CGRectOffset(labelFrame, 0, -layoutParameters.labelFont.descender)) options:0];
  
  // Draw thumbnail, error sign or nothing
  if (showsErrorSign)
    [errorImage compositeToPoint:NSPointFromCGPoint(thumbnailFrame.origin) operation:NSCompositeSourceOver];
  else if (!(CGRectIsEmpty(thumbnailFrame) || [evaluatedExpression isError])) {
    CIContext* ctx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort] options:[NSDictionary dictionary]]; // TODO: working color space
    CIImage* image = [(IFImageConstantExpression*)evaluatedExpression imageValueCI];
    CGRect sourceRect = CGRectMake(CGRectGetMinX(image.extent), CGRectGetMinY(image.extent), CGRectGetWidth(thumbnailFrame), CGRectGetHeight(thumbnailFrame));
    [ctx drawImage:image inRect:thumbnailFrame fromRect:sourceRect];
    
    // Draw mask tag, if needed
    if (isMask) {
      NSPoint maskOrigin = NSMakePoint(CGRectGetMaxX(thumbnailFrame) - maskImage.size.width, CGRectGetMinY(thumbnailFrame));
      [maskImage compositeToPoint:maskOrigin operation:NSCompositeSourceOver];
    }    
  }
  
  // Draw alias arrow, if needed
  if ([node isAlias])
    [aliasImage compositeToPoint:NSPointFromCGPoint(thumbnailFrame.origin) operation:NSCompositeSourceOver];
  
  // Draw name, if any
  if (!CGRectIsEmpty(nameFrame)) {
    NSAttributedString* name = [[[NSAttributedString alloc] initWithString:@"name" attributes:textAttrs] autorelease]; // TODO: use real node name
    [[NSColor yellowColor] set];
    [NSBezierPath fillRect:NSRectFromCGRect(nameFrame)];
    [name drawWithRect:NSRectFromCGRect(CGRectOffset(nameFrame, 0, -layoutParameters.labelFont.descender)) options:0];
  }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == IFCanvasBoundsChangedContext) {
    [self updateExpression];
  } else if (context == IFColumnWidthChangedContext) {
    [self updateExpression];
    [self updateInternalLayout];
  } else if (context == IFExpressionChangedContext) {
    [self updateExpression];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end

@implementation IFNodeLayer (Private)

- (void)setThumbnailAspectRatio:(float)newRatio;
{
  BOOL updateLayout = fabs(newRatio - thumbnailAspectRatio) > 0.00001;
  thumbnailAspectRatio = newRatio;
  if (updateLayout)
    [self updateInternalLayout];
}

- (float)thumbnailAspectRatio;
{
  return thumbnailAspectRatio;
}

- (void)setEvaluatedExpression:(IFConstantExpression*)newEvaluatedExpression;
{
  if (newEvaluatedExpression != evaluatedExpression) {
    [evaluatedExpression release];
    evaluatedExpression = [newEvaluatedExpression retain];
  }
}

- (IFConstantExpression*)evaluatedExpression;
{
  return evaluatedExpression;
}

- (void)updateExpression;
{
  const float margin = layoutParameters.nodeInternalMargin;
  
  if (self.evaluatedExpression != nil)
    self.evaluatedExpression = nil;
  
  IFExpression* nodeExpression = node.expression;
  if (nodeExpression == nil)
    return;
  
  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  IFConstantExpression* basicExpression = [evaluator evaluateExpression:nodeExpression];
  if (![basicExpression isError]) {
    CGRect canvasBounds = layoutParameters.canvasBounds;
    IFExpression* imageExpression = [evaluator evaluateExpressionAsImage:basicExpression];
    IFExpression* croppedExpression = [IFOperatorExpression crop:imageExpression along:NSRectFromCGRect(canvasBounds)];
    const float maxSide = layoutParameters.columnWidth - 2.0 * margin;
    const float scaling = maxSide / fmax(CGRectGetWidth(canvasBounds), CGRectGetHeight(canvasBounds));
    IFExpression* scaledCroppedExpression = [IFOperatorExpression resample:croppedExpression by:scaling];
    self.evaluatedExpression = [evaluator evaluateExpression:scaledCroppedExpression];
    showsErrorSign = NO;
    self.thumbnailAspectRatio = CGRectIsEmpty(canvasBounds) ? 0.0 : CGRectGetWidth(canvasBounds) / CGRectGetHeight(canvasBounds);
    isMask = [[(IFImageConstantExpression*)basicExpression image] kind] == IFImageKindMask;
  } else {
    self.evaluatedExpression = basicExpression;
    showsErrorSign = ([(IFErrorConstantExpression*)basicExpression message] != nil);
    self.thumbnailAspectRatio = 0.0;
  }
  
  [self setNeedsDisplay];
}

- (void)updateInternalLayout;
{
  const float margin = layoutParameters.nodeInternalMargin;
  const float externalWidth = layoutParameters.columnWidth;
  const float internalWidth = externalWidth - 2.0 * margin;
  CGRect internalFrame = CGRectNull;
  
  float x = margin, y = margin;

  // Name (if any)
  if (node.name != nil) {
    nameFrame = CGRectMake(x, y, internalWidth, layoutParameters.labelFontHeight);
    internalFrame = CGRectUnion(internalFrame, nameFrame);
    y += CGRectGetHeight(nameFrame) + margin;
  } else
    nameFrame = CGRectZero;
  
  // Thumbnail (if any) / error sign
  if (showsErrorSign) {
    NSSize imageSize = [errorImage size];
    thumbnailFrame = CGRectMake(x + (internalWidth - imageSize.width) / 2.0, y, imageSize.width, imageSize.height);
    internalFrame = CGRectUnion(internalFrame, thumbnailFrame);
    y += CGRectGetHeight(thumbnailFrame) + margin;
  } else if (thumbnailAspectRatio != 0.0) {
    thumbnailFrame = (thumbnailAspectRatio <= 1.0)
    ? CGRectMake(x + round(internalWidth * (1.0 - thumbnailAspectRatio) / 2.0), y, floor(internalWidth * thumbnailAspectRatio), internalWidth)
    : CGRectMake(x, y, internalWidth, floor(internalWidth / thumbnailAspectRatio));
    internalFrame = CGRectUnion(internalFrame, thumbnailFrame);
    y += CGRectGetHeight(thumbnailFrame) + margin;
  } else
    thumbnailFrame = CGRectZero;

  // Label
  labelFrame = CGRectMake(x, y, internalWidth, layoutParameters.labelFontHeight);
  y += CGRectGetHeight(labelFrame);
  internalFrame = CGRectUnion(internalFrame, labelFrame);

  CGRect externalFrame = CGRectInset(internalFrame, -margin, -margin);
  NSAssert(fabs(CGRectGetWidth(externalFrame) - layoutParameters.columnWidth) < 0.001, @"invalid external frame");
  
  // Outline path
  NSBezierPath* outline = [NSBezierPath bezierPath];
  if (isSink) {
    [outline moveToPoint:NSZeroPoint];
    [outline lineToPoint:NSMakePoint(CGRectGetMaxX(externalFrame), CGRectGetMinY(externalFrame))];
  } else {
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(CGRectGetMinX(internalFrame), CGRectGetMinY(internalFrame)) radius:margin startAngle:180 endAngle:-90];
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(CGRectGetMaxX(internalFrame), CGRectGetMinY(internalFrame)) radius:margin startAngle:-90 endAngle:0];
  }
  if (isSource) {
    [outline lineToPoint:NSMakePoint(CGRectGetMaxX(externalFrame), CGRectGetMaxY(externalFrame))];
    [outline lineToPoint:NSMakePoint(CGRectGetMinX(externalFrame), CGRectGetMaxY(externalFrame))];
  } else {
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(CGRectGetMaxX(internalFrame), CGRectGetMaxY(internalFrame)) radius:margin startAngle:0 endAngle:90];
    [outline appendBezierPathWithArcWithCenter:NSMakePoint(CGRectGetMinX(internalFrame), CGRectGetMaxY(internalFrame)) radius:margin startAngle:90 endAngle:180];
  }
  [outline closePath];
  
  self.outlinePath = outline;
  [self.superlayer setNeedsLayout];
}

@end
